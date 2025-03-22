from flask import Flask, render_template_string, request
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

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        name = request.form.get('name', 'Guest')
        color = request.form.get('color', os.getenv('COLOR', 'red'))
        return render_template_string(f"""
        <html>
            <head><title>Welcome</title></head>
            <body style='background-color:{color}; text-align:center; padding-top:50px; color:white;'>
                <h1>Welcome, {name}!</h1>
                <p>Thanks for joining Devopclinics community 💡</p>
            </body>
        </html>
        """)
    
    return render_template_string("""
    <html>
        <head><title>Join Us</title></head>
        <body style="text-align:center; padding-top:50px;">
            <h2>Enter Your Name and Favorite Color</h2>
            <form method="POST">
                <input type="text" name="name" placeholder="Your Name" required><br><br>
                <input type="text" name="color" placeholder="Favorite Color" required><br><br>
                <button type="submit">Submit</button>
            </form>
        </body>
    </html>
    """)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
