#!/home/maykon/.openclaw/workspace/venv/bin/python3
"""
Integração Google Calendar + Tasks para Midnight Claw
Lê eventos e tarefas e salva em JSON para o heartbeat consumir
"""

import os
import json
from datetime import datetime, timedelta
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

# Configurações
SCOPES = [
    'https://www.googleapis.com/auth/calendar.readonly',
    'https://www.googleapis.com/auth/tasks.readonly'
]
CREDENTIALS_FILE = os.path.expanduser('~/.config/google/credentials.json')
TOKEN_FILE = os.path.expanduser('~/.config/google/token.json')
OUTPUT_DIR = os.path.expanduser('~/.openclaw/workspace/memory')

def authenticate():
    """Autentica com Google OAuth e retorna credenciais válidas"""
    creds = None
    
    # Carrega token existente se houver
    if os.path.exists(TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
    
    # Se não tem credenciais ou estão expiradas
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_FILE, SCOPES)
            
            # Define redirect URI explicitamente
            flow.redirect_uri = 'http://localhost'
            
            # Fluxo manual para SSH/headless
            auth_url, _ = flow.authorization_url(prompt='consent', access_type='offline')
            print("\n" + "="*60)
            print("Abra esta URL no navegador:")
            print(auth_url)
            print("="*60)
            
            # Solicita código de autorização
            code = input("\nCole o código de autorização aqui: ").strip()
            
            # Troca código por token
            flow.fetch_token(code=code)
            creds = flow.credentials
        
        # Salva token para próxima execução
        with open(TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())
    
    return creds

def get_calendar_events(service, days=2):
    """Busca eventos do calendário para os próximos N dias"""
    now = datetime.utcnow()
    end = now + timedelta(days=days)
    
    events_result = service.events().list(
        calendarId='primary',
        timeMin=now.isoformat() + 'Z',
        timeMax=end.isoformat() + 'Z',
        singleEvents=True,
        orderBy='startTime'
    ).execute()
    
    events = events_result.get('items', [])
    
    result = []
    for event in events:
        start = event['start'].get('dateTime', event['start'].get('date'))
        result.append({
            'summary': event.get('summary', 'Sem título'),
            'start': start,
            'location': event.get('location', ''),
            'description': event.get('description', '')
        })
    
    return result

def get_tasks(service):
    """Busca tarefas pendentes do Google Tasks"""
    # Lista todas as task lists
    task_lists = service.tasklists().list().execute().get('items', [])
    
    all_tasks = []
    for task_list in task_lists:
        tasks = service.tasks().list(
            tasklist=task_list['id'],
            showCompleted=False,
            showHidden=False
        ).execute().get('items', [])
        
        for task in tasks:
            all_tasks.append({
                'title': task.get('title', 'Sem título'),
                'notes': task.get('notes', ''),
                'due': task.get('due', ''),
                'list': task_list['title']
            })
    
    return all_tasks

def main():
    """Função principal"""
    print("Autenticando com Google...")
    creds = authenticate()
    
    # Build services
    calendar_service = build('calendar', 'v3', credentials=creds)
    tasks_service = build('tasks', 'v1', credentials=creds)
    
    # Busca dados
    print("Buscando eventos do calendário...")
    events = get_calendar_events(calendar_service)
    
    print("Buscando tarefas...")
    tasks = get_tasks(tasks_service)
    
    # Salva resultados
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    output = {
        'updated_at': datetime.now().isoformat(),
        'calendar': events,
        'tasks': tasks
    }
    
    output_file = os.path.join(OUTPUT_DIR, 'google-data.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Dados salvos em {output_file}")
    print(f"   Eventos: {len(events)}")
    print(f"   Tarefas: {len(tasks)}")
    
    return output

if __name__ == '__main__':
    main()
