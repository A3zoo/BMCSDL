from flask import Flask
from blueprints.auth_blueprint import auth_views
from flask_login import LoginManager
from bson import ObjectId
from flask import Flask, session, redirect, url_for, request, render_template
from blueprints import auth_blueprint
# create an instance of the flask application
app = Flask(__name__)

app.secret_key = "ENTER_YOUR_SECRET_KEY"


@app.route('/')
def index():
    return render_template('login.html')

app.register_blueprint(auth_views)

if __name__ == "__main__":
    app.run(debug=True)

