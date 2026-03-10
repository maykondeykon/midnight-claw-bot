#!/usr/bin/env python3
"""
Script para quebrar senha de arquivos .doc (Word 97-2003)
Uso: python3 crack_doc_password.py <arquivo.doc> [wordlist.txt]
"""

import sys
import os
import time
from itertools import product

try:
    import msoffcrypto
except ImportError:
    print("Instalando msoffcrypto-tool...")
    os.system("pip install msoffcrypto-tool")
    import msoffcrypto

def try_password(filepath, password):
    """Tenta abrir o arquivo com uma senha"""
    try:
        with open(filepath, 'rb') as f:
            file = msoffcrypto.OfficeFile(f)
            file.load_key(password=password)
            # Se chegou aqui, a senha está correta
            return True
    except Exception:
        return False

def brute_force_simple(filepath, max_length=6):
    """Brute force com caracteres comuns"""
    chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
    print(f"\n[+] Iniciando brute force (até {max_length} caracteres)...")
    print(f"[+] Caracteres: {chars}")
    
    total = sum(len(chars) ** i for i in range(1, max_length + 1))
    tried = 0
    
    for length in range(1, max_length + 1):
        for combo in product(chars, repeat=length):
            password = ''.join(combo)
            tried += 1
            
            if tried % 1000 == 0:
                print(f"[*] Testadas: {tried}/{total} senhas...", end='\r')
            
            if try_password(filepath, password):
                return password
    
    return None

def wordlist_attack(filepath, wordlist_path):
    """Ataque com lista de palavras"""
    if not os.path.exists(wordlist_path):
        print(f"[-] Wordlist não encontrada: {wordlist_path}")
        return None
    
    print(f"\n[+] Iniciando ataque com wordlist: {wordlist_path}")
    
    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.strip() for line in f if line.strip()]
    
    total = len(passwords)
    print(f"[+] {total} senhas para testar")
    
    for i, password in enumerate(passwords):
        if (i + 1) % 100 == 0:
            print(f"[*] Testadas: {i+1}/{total} senhas...", end='\r')
        
        if try_password(filepath, password):
            return password
    
    return None

def common_passwords_attack(filepath):
    """Tenta senhas comuns primeiro"""
    common = [
        # Senhas comuns em português
        'senha', 'senha123', 'senha1234', 'senha12345',
        'minhasenha', 'password', 'password1', 'password123',
        '123456', '1234567', '12345678', '123456789', '1234567890',
        'admin', 'admin123', 'administrador',
        'midnight', 'midnight1', 'midnight123',
        'rider', 'midnight rider', 'midnightrider',
        # Dados pessoais comuns
        'maykon', 'maykon123', 'cristina', 'arthur', 'aurora',
        # Anos
        '1981', '19811', '2004', '2005', '2006', '2007', '2008', '2009', '2010',
        '2011', '2012', '2013', '2014',
        # Bandas/músicas
        'metal', 'metallica', 'ironmaiden', 'megadeth',
        'rock', 'rocknroll', 'heavymetal',
        # Genéricas
        'letmein', 'welcome', 'qwerty', 'abc123', 'monkey',
        'master', 'dragon', '111111', '000000', '654321',
        '', ' ', '  ', '   ',  # Senhas vazias ou espaços
    ]
    
    # Variações comuns
    variations = []
    for p in common:
        variations.append(p)
        variations.append(p.upper())
        variations.append(p.capitalize())
        variations.append(p + '!')
        variations.append(p + '@')
        variations.append(p + '#')
    
    print(f"\n[+] Tentando {len(variations)} senhas comuns...")
    
    for i, password in enumerate(variations):
        if try_password(filepath, password):
            return password
    
    return None

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 crack_doc_password.py <arquivo.doc> [wordlist.txt]")
        print("\nExemplos:")
        print("  python3 crack_doc_password.py letra.doc")
        print("  python3 crack_doc_password.py letra.doc rockyou.txt")
        sys.exit(1)
    
    filepath = sys.argv[1]
    
    if not os.path.exists(filepath):
        print(f"[-] Arquivo não encontrado: {filepath}")
        sys.exit(1)
    
    print(f"\n{'='*60}")
    print(f"QUEBRA DE SENHA - ARQUIVO .DOC")
    print(f"{'='*60}")
    print(f"[*] Arquivo: {filepath}")
    print(f"[*] Tamanho: {os.path.getsize(filepath)} bytes")
    
    start_time = time.time()
    found_password = None
    
    # Fase 1: Senhas comuns
    print("\n[FASE 1] Testando senhas comuns...")
    found_password = common_passwords_attack(filepath)
    
    # Fase 2: Wordlist (se fornecida)
    if not found_password and len(sys.argv) > 2:
        print("\n[FASE 2] Ataque com wordlist...")
        found_password = wordlist_attack(filepath, sys.argv[2])
    
    # Fase 3: Brute force (se solicitado)
    if not found_password:
        resposta = input("\n[?] Tentar brute force? (pode demorar) [s/N]: ")
        if resposta.lower() == 's':
            print("\n[FASE 3] Brute force...")
            found_password = brute_force_simple(filepath, max_length=5)
    
    # Resultado
    elapsed = time.time() - start_time
    print(f"\n\n{'='*60}")
    
    if found_password:
        print(f"✅ SENHA ENCONTRADA: '{found_password}'")
        print(f"[*] Tempo: {elapsed:.2f} segundos")
        print(f"\n[+] Para descriptografar o arquivo:")
        print(f"    msoffcrypto-tool {filepath} -p '{found_password}' -o {filepath}.decrypted.doc")
    else:
        print("❌ Senha não encontrada")
        print(f"[*] Tempo: {elapsed:.2f} segundos")
        print("\nSugestões:")
        print("  1. Tente com uma wordlist maior")
        print("  2. Aumente o max_length no brute force")
        print("  3. Lembre de padrões que usava na época")
    
    print(f"{'='*60}\n")

if __name__ == '__main__':
    main()
