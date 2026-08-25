from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return '<h1>سلام! این سایت داخل GitHub Actions ران شده 🎉</h1>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
