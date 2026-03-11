#!/usr/bin/env python3
"""
Script para quebrar senha de arquivos .doc (Word 97-2003)
Uso: python3 crack_doc_password.py <arquivo.doc> [wordlist.txt]

Funcionalidades:
  - Salva progresso e retoma de onde parou
  - Grava senha encontrada em arquivo .txt
  - Log em tempo real para acompanhar progresso
"""

import sys
import os
import time
import json
import signal
from itertools import product, islice
from datetime import datetime

try:
    import msoffcrypto
except ImportError:
    import subprocess
    print("Instalando msoffcrypto-tool...")
    # Tenta todas as variações comuns de pip
    cmds = [
        [sys.executable, "-m", "pip", "install", "msoffcrypto-tool", "--break-system-packages", "-q"],
        [sys.executable, "-m", "pip", "install", "msoffcrypto-tool", "-q"],
        ["pip3", "install", "msoffcrypto-tool", "--break-system-packages", "-q"],
        ["pip3", "install", "msoffcrypto-tool", "-q"],
        ["pip",  "install", "msoffcrypto-tool", "--break-system-packages", "-q"],
        ["pip",  "install", "msoffcrypto-tool", "-q"],
    ]
    installed = False
    for cmd in cmds:
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                installed = True
                break
        except FileNotFoundError:
            continue
    if not installed:
        print("ERRO: Não foi possível instalar msoffcrypto-tool automaticamente.")
        print("Instale manualmente com:  pip install msoffcrypto-tool")
        sys.exit(1)
    import msoffcrypto

# ──────────────────────────────────────────────
# Arquivos de estado / log
# ──────────────────────────────────────────────
def get_state_paths(filepath):
    base = os.path.splitext(filepath)[0]
    return {
        "checkpoint": base + "_checkpoint.json",
        "result":     base + "_senha_encontrada.txt",
        "log":        base + "_progress.log",
    }

def log(paths, msg, also_print=True):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    with open(paths["log"], "a", encoding="utf-8") as f:
        f.write(line + "\n")
    if also_print:
        print(line)

def save_checkpoint(paths, data):
    with open(paths["checkpoint"], "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def load_checkpoint(paths):
    if os.path.exists(paths["checkpoint"]):
        with open(paths["checkpoint"], "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def save_result(paths, password):
    with open(paths["result"], "w", encoding="utf-8") as f:
        f.write(f"SENHA ENCONTRADA: {password}\n")
        f.write(f"Data/hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

# ──────────────────────────────────────────────
# Tentativa de senha
# ──────────────────────────────────────────────
def try_password(filepath, password):
    try:
        with open(filepath, "rb") as f:
            office_file = msoffcrypto.OfficeFile(f)
            office_file.load_key(password=password)
            return True
    except Exception:
        return False

# ──────────────────────────────────────────────
# Fase 1 – Senhas comuns
# ──────────────────────────────────────────────
def common_passwords_attack(filepath, paths, checkpoint):
    if checkpoint.get("phase_done", {}).get("common"):
        log(paths, "[FASE 1] Já concluída anteriormente. Pulando.")
        return None

    common = [
        "senha", "senha123", "senha1234", "senha12345",
        "minhasenha", "password", "password1", "password123",
        "123456", "1234567", "12345678", "123456789", "1234567890",
        "admin", "admin123", "administrador",
        "midnight", "midnight1", "midnight123",
        "rider", "midnight rider", "midnightrider",
        "maykon", "maykon123", "cristina", "arthur", "aurora",
        "1981", "2004", "2005", "2006", "2007", "2008", "2009",
        "2010", "2011", "2012", "2013", "2014",
        "metal", "metallica", "ironmaiden", "megadeth",
        "rock", "rocknroll", "heavymetal",
        "letmein", "welcome", "qwerty", "abc123", "monkey",
        "master", "dragon", "111111", "000000", "654321",
        "", " ", "  ", "   ",
    ]

    variations = []
    for p in common:
        variations += [p, p.upper(), p.capitalize(),
                       p + "!", p + "@", p + "#"]

    log(paths, f"[FASE 1] Testando {len(variations)} senhas comuns...")
    for i, password in enumerate(variations):
        if (i + 1) % 50 == 0:
            log(paths, f"[FASE 1] {i+1}/{len(variations)} testadas...", also_print=False)
            print(f"\r[FASE 1] {i+1}/{len(variations)} testadas...", end="", flush=True)
        if try_password(filepath, password):
            print()
            return password

    print()
    checkpoint.setdefault("phase_done", {})["common"] = True
    save_checkpoint(paths, checkpoint)
    log(paths, "[FASE 1] Concluída sem resultado.")
    return None

# ──────────────────────────────────────────────
# Fase 2 – Wordlist
# ──────────────────────────────────────────────
def wordlist_attack(filepath, wordlist_path, paths, checkpoint):
    if checkpoint.get("phase_done", {}).get("wordlist"):
        log(paths, "[FASE 2] Já concluída anteriormente. Pulando.")
        return None

    if not os.path.exists(wordlist_path):
        log(paths, f"[FASE 2] Wordlist não encontrada: {wordlist_path}")
        return None

    resume_from = checkpoint.get("wordlist_resume", 0)

    with open(wordlist_path, "r", encoding="utf-8", errors="ignore") as f:
        passwords = [line.strip() for line in f if line.strip()]

    total = len(passwords)
    log(paths, f"[FASE 2] {total} senhas na wordlist. Retomando do índice {resume_from}.")

    for i in range(resume_from, total):
        password = passwords[i]
        if (i + 1) % 500 == 0:
            log(paths, f"[FASE 2] {i+1}/{total} testadas...", also_print=False)
            print(f"\r[FASE 2] {i+1}/{total} testadas...", end="", flush=True)
            # Salva checkpoint a cada 500
            checkpoint["wordlist_resume"] = i + 1
            save_checkpoint(paths, checkpoint)

        if try_password(filepath, password):
            print()
            return password

    print()
    checkpoint.setdefault("phase_done", {})["wordlist"] = True
    checkpoint["wordlist_resume"] = 0
    save_checkpoint(paths, checkpoint)
    log(paths, "[FASE 2] Concluída sem resultado.")
    return None

# ──────────────────────────────────────────────
# Fase 3 – Brute force
# ──────────────────────────────────────────────
def _combo_index(combo, chars):
    """Converte uma combinação no seu índice global (para checkpoint)."""
    base = len(chars)
    idx = 0
    for c in combo:
        idx = idx * base + chars.index(c)
    return idx

def brute_force(filepath, paths, checkpoint, max_length=6):
    if checkpoint.get("phase_done", {}).get("brute"):
        log(paths, "[FASE 3] Já concluída anteriormente. Pulando.")
        return None

    chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    log(paths, f"[FASE 3] Brute force até {max_length} chars. Charset: {chars}")

    resume_length = checkpoint.get("brute_length", 1)
    resume_index  = checkpoint.get("brute_index",  0)

    for length in range(resume_length, max_length + 1):
        total = len(chars) ** length
        start = resume_index if length == resume_length else 0

        log(paths, f"[FASE 3] Comprimento {length}: {total} combinações (início: {start})")

        gen = islice(product(chars, repeat=length), start, None)
        tried = start

        for combo in gen:
            password = "".join(combo)
            tried += 1

            if tried % 2000 == 0:
                log(paths, f"[FASE 3] len={length} {tried}/{total} ({100*tried//total}%)",
                    also_print=False)
                print(f"\r[FASE 3] len={length}  {tried}/{total} ({100*tried//total}%)  última: '{password}'",
                      end="", flush=True)
                # Checkpoint a cada 2000
                checkpoint["brute_length"] = length
                checkpoint["brute_index"]  = tried
                save_checkpoint(paths, checkpoint)

            if try_password(filepath, password):
                print()
                return password

        # Terminou este comprimento
        checkpoint["brute_length"] = length + 1
        checkpoint["brute_index"]  = 0
        save_checkpoint(paths, checkpoint)
        log(paths, f"[FASE 3] Comprimento {length} concluído.")

    print()
    checkpoint.setdefault("phase_done", {})["brute"] = True
    save_checkpoint(paths, checkpoint)
    log(paths, "[FASE 3] Brute force concluído sem resultado.")
    return None

# ──────────────────────────────────────────────
# Tratamento de CTRL+C limpo
# ──────────────────────────────────────────────
_paths_global = None

def handle_interrupt(sig, frame):
    print("\n\n[!] Interrompido. Progresso salvo. Execute novamente para continuar.")
    if _paths_global:
        log(_paths_global, "[!] Script interrompido pelo usuário. Checkpoint salvo.")
    sys.exit(0)

signal.signal(signal.SIGINT,  handle_interrupt)
signal.signal(signal.SIGTERM, handle_interrupt)

# ──────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────
def main():
    global _paths_global

    if len(sys.argv) < 2:
        print("Uso: python3 crack_doc_password.py <arquivo.doc> [wordlist.txt]")
        sys.exit(1)

    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"[-] Arquivo não encontrado: {filepath}")
        sys.exit(1)

    paths = get_state_paths(filepath)
    _paths_global = paths

    checkpoint = load_checkpoint(paths)
    resuming = bool(checkpoint)

    log(paths, "=" * 60)
    log(paths, f"QUEBRA DE SENHA  –  {filepath}")
    log(paths, f"Tamanho: {os.path.getsize(filepath)} bytes")
    if resuming:
        log(paths, "Retomando sessão anterior...")
    log(paths, f"Log:        {paths['log']}")
    log(paths, f"Checkpoint: {paths['checkpoint']}")
    log(paths, f"Resultado:  {paths['result']}")
    log(paths, "=" * 60)

    start_time = time.time()
    found = None

    # ── Fase 1
    if not found:
        found = common_passwords_attack(filepath, paths, checkpoint)

    # ── Fase 2
    if not found and len(sys.argv) > 2:
        found = wordlist_attack(filepath, sys.argv[2], paths, checkpoint)

    # ── Fase 3
    if not found:
        found = brute_force(filepath, paths, checkpoint, max_length=6)

    # ── Resultado
    elapsed = time.time() - start_time
    log(paths, "=" * 60)

    if found:
        log(paths, f"✅  SENHA ENCONTRADA: '{found}'")
        log(paths, f"Tempo total: {elapsed:.2f}s")
        save_result(paths, found)
        log(paths, f"Senha gravada em: {paths['result']}")
        log(paths, f"\nPara descriptografar:")
        log(paths, f"  msoffcrypto-tool {filepath} -p '{found}' -o decriptado.doc")
        # Limpa checkpoint pois já terminou
        if os.path.exists(paths["checkpoint"]):
            os.remove(paths["checkpoint"])
    else:
        log(paths, "❌  Senha não encontrada.")
        log(paths, f"Tempo total: {elapsed:.2f}s")
        log(paths, "Sugestões: forneça uma wordlist maior ou aumente max_length.")

    log(paths, "=" * 60)

if __name__ == "__main__":
    main()
