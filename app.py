from flask import Flask, render_template_string, request, make_response
import os

app = Flask(__name__)

@app.after_request
def add_security_headers(response):
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Server"] = "SecureServer"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
    return response

@app.route('/')
@app.route('/<color>')
def display_pattern(color=None):
    color = color or os.getenv('COLOR', 'red')
    html = f"""
    <html><head><style>
    .moving-text {{ font-size: 48px; animation: move 5s linear infinite; }}
    @keyframes move {{ 0% {{ top: 0; left: 0; }} 100% {{ top: 0; left: 0; }} }}
    </style></head>
    <body style='background-color:{color}'><div class='moving-text'>Happy Learning!</div></body></html>
    """
    return render_template_string(html)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)