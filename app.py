from pathlib import Path

from flask import Flask, jsonify

app = Flask(__name__)

version_file = Path(__file__).with_name("VERSION")

VERSION = (
    version_file.read_text().strip()
    if version_file.exists()
    else "local"
)


@app.route("/")
def index():
    return (
        "<h1>Lab 10 - Flask application</h1>"
        "<p>Application successfully deployed!</p>"
        "<p>Deployment method: SSH + systemd</p>"
        f"<p>Version: {VERSION}</p>"
    )


@app.route("/health")
def health():
    return jsonify(
        status="ok",
        service="lab10-flask",
        version=VERSION
    ), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
