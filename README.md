# YapIt 🗣️🔐

**YapIt** is a minimalist CLI for secure, cloud-free venting. It transforms your thoughts into a local-first vault using **RSA-2048** encryption.

In therapy, you act as the **Writer** (Public Key), while your therapist is the **Reader** (Private Key). This ensures you cannot re-read or over-analyze your "yaps" until your next session.

---

## Features
* **100% Local:** No servers, logs, or third-party APIs.
* **Asymmetric Security:** RSA-2048 + OAEP padding for maximum isolation.
* **Automatic Archiving:** Sessions are chronologically indexed by Unix EPOCH time.
* **Write-Only Flow:** Designed to prevent self-rumination by separating encryption and decryption roles.

---

## How It Works
1.  **Yap Mode:** Your text is sliced into 180-byte chunks and locked with the Public Key.
2.  **The Vault:** Encrypted chunks are stored in `yaps/[timestamp]/`, indecipherable without the corresponding private key.
3.  **Unpack Mode:** The Private Key reverses the encryption to display the original text in the terminal.

---

## Setup & Installation

### 1. Prerequisites
Requires `openssl` and `coreutils`.
**Linux / WSL:**
```bash
sudo apt update && sudo apt install openssl coreutils -y
```

### 2. Clone & Prep
```bash
git clone <your-repo-url>
cd yapit
chmod +x yapit.sh
```

### 3. The Therapist Protocol
* **Initialize:** Run `./yapit.sh` and select Option 1 to generate the `keys/` directory.
* **Handover:** Move `keys/id_rsa` (Private Key) to your therapist (via USB or Signal) and immediately delete the local copy: `rm keys/id_rsa`.
* **Lock:** Keep `keys/id_rsa.pub` (Public Key) on your machine to stay in **Write-Only** mode.

---

## Usage

### 🔓 Yap (Lock thoughts)
Select Option 1, type your session, and press `Ctrl+D` to encrypt.

### 🔑 Unpack (Session Day)
On session day, restore `id_rsa` to the `keys/` folder and select Option 2 to decrypt a specific timestamp.

---

## Technical Overview

### Why 180 bytes?
RSA-OAEP with SHA-256 ($hLen = 32$) limits the payload ($M_{max}$) of a 2048-bit key ($L = 256$):

$$M_{max} = L - 2 \cdot hLen - 2 = 190 \text{ bytes}$$

We use 180 bytes as a safe ceiling to prevent padding errors with multi-byte UTF-8 characters.

### Stack
* **Algorithm:** RSA-2048
* **Padding:** OAEP + SHA-256
* **Encoding:** Base64

### Project Structure
```text
.
├── yapit.sh          # Orchestrator
├── keys/
│   ├── id_rsa        # PRIVATE (Therapist's Key - Delete after setup)
│   └── id_rsa.pub    # PUBLIC (Your Key - Keep this)
└── yaps/
    └── 1741638200/   # Encrypted session blocks
```

Built for yappers and the security-conscious.