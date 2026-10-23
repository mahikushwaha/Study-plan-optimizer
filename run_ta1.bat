@echo off
cd /d "%~dp0"
if not exist venv\Scripts\python.exe python -m venv venv
call venv\Scripts\activate.bat
python -m pip install -r requirements.txt
echo Open http://127.0.0.1:5000
cd ta1
python app.py
pause
