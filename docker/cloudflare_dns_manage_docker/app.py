import os, sqlite3, requests
from fastapi import FastAPI, Request, Form, Depends, HTTPException, Body
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from passlib.context import CryptContext

app = FastAPI()
app.add_middleware(SessionMiddleware, secret_key="CF_STABLE_99_KEY") 
templates = Jinja2Templates(directory="templates")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

DB_PATH = "data/config.db"
CF_API_URL = "https://api.cloudflare.com/client/v4"

def init_db():
    os.makedirs("data", exist_ok=True)
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("CREATE TABLE IF NOT EXISTS users (username TEXT PRIMARY KEY, password TEXT)")
        conn.execute("CREATE TABLE IF NOT EXISTS zones (zone_id TEXT PRIMARY KEY, name TEXT, token TEXT)")
init_db()

def get_user(request: Request):
    return request.session.get("user")

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    with sqlite3.connect(DB_PATH) as conn:
        if not conn.execute("SELECT 1 FROM users").fetchone():
            return templates.TemplateResponse("setup.html", {"request": request})
    if not get_user(request): 
        return RedirectResponse("/login")
    return templates.TemplateResponse("index.html", {"request": request, "user": get_user(request)})

@app.get("/login", response_class=HTMLResponse)
async def login_p(request: Request): 
    return templates.TemplateResponse("login.html", {"request": request})

@app.post("/setup")
async def setup(username: str = Form(...), password: str = Form(...)):
    with sqlite3.connect(DB_PATH) as conn:
        if not conn.execute("SELECT 1 FROM users").fetchone():
            conn.execute("INSERT INTO users VALUES (?,?)", (username, pwd_context.hash(password[:71])))
            conn.commit()
    return RedirectResponse("/login", status_code=303)

@app.post("/auth")
async def auth(request: Request, username: str = Form(...), password: str = Form(...)):
    with sqlite3.connect(DB_PATH) as conn:
        row = conn.execute("SELECT password FROM users WHERE username=?", (username,)).fetchone()
        if row and pwd_context.verify(password[:71], row[0]):
            request.session["user"] = username
            return RedirectResponse("/", status_code=303)
    return HTMLResponse(content="<script>alert('账号或密码错误！'); window.location.href='/login';</script>")

@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login")

@app.get("/api/zones")
async def list_zones(user=Depends(get_user)):
    if not user: return []
    with sqlite3.connect(DB_PATH) as conn:
        return [{"name": r[0], "zoneId": r[1]} for r in conn.execute("SELECT name, zone_id FROM zones").fetchall()]

@app.post("/api/zones")
async def add_zone(data: dict = Body(...), user=Depends(get_user)):
    if not user: raise HTTPException(401)
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("INSERT OR REPLACE INTO zones VALUES (?,?,?)", (data['zoneId'], data['name'], data['token']))
        conn.commit()
    return {"success": True}

@app.delete("/api/zones/{zid}")
async def del_zone(zid: str, user=Depends(get_user)):
    if not user: raise HTTPException(401)
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("DELETE FROM zones WHERE zone_id=?", (zid,))
        conn.commit()
    return {"success": True}

@app.api_route("/api/cf/{zid}/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def cf_proxy(request: Request, zid: str, path: str, user=Depends(get_user)):
    if not user: raise HTTPException(401)
    with sqlite3.connect(DB_PATH) as conn:
        row = conn.execute("SELECT token FROM zones WHERE zone_id=?", (zid,)).fetchone()
    if not row: return {"success": False, "errors": [{"message": "未找到 Token"}]}
    
    url = f"{CF_API_URL}/zones/{zid}/dns_records" + (f"/{path}" if path else "")
    headers = {"Authorization": f"Bearer {row[0]}", "Content-Type": "application/json"}
    
    json_body = None
    if request.method in ["POST", "PUT"]:
        try:
            raw_data = await request.json()
            json_body = {k: v for k, v in raw_data.items() if k in ['type', 'name', 'content', 'proxied', 'ttl', 'priority']}
        except: pass
            
    res = requests.request(request.method, url, headers=headers, json=json_body)
    return res.json()