#!/usr/bin/env python3
import requests
import json
import os

WORMHOLE_URL = "http://127.0.0.1:5021/ui-action"
VAULT_PATH = os.path.expanduser("~/BuildCo_LLM_Node/vault_state.json")

def open_url(url):
    payload = {"action": "open_url", "url": url}
    response = requests.post(WORMHOLE_URL, json=payload)
    print(f"[Agent Response] {response.status_code} - {response.text}")

def show_vault():
    try:
        with open(VAULT_PATH, 'r') as f:
            data = json.load(f)
            print("\n🔐 Vault State:")
            print(json.dumps(data, indent=2))
    except Exception as e:
        print(f"Error reading vault: {e}")

def menu():
    while True:
        print("\n🌀 Wormhole Console")
        print("1. Open Pastebin")
        print("2. Show Vault State")
        print("3. Enter Custom URL")
        print("4. Exit")

        choice = input("Enter your choice: ")
        if choice == "1":
            open_url("https://pastebin.com")
        elif choice == "2":
            show_vault()
        elif choice == "3":
            url = input("Enter URL: ")
            open_url(url)
        elif choice == "4":
            print("Exiting console.")
            break
        else:
            print("Invalid option.")

if __name__ == "__main__":
    menu()

