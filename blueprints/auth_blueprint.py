from flask import Blueprint, request, render_template, redirect, flash
from flask_login import login_required, logout_user, current_user, login_user
from database import get_session, session as db_session
from flask import Flask, session, redirect, url_for, request
from models.UserLogin import login_duy

auth_views = Blueprint("auth", __name__)

@auth_views.route("/login", strict_slashes=False, methods=["GET", "POST"])
def login():    
    if request.method == "POST":
        sdt = request.form.get("sdt")
        user_password = request.form.get("password")

        result = login_duy(db_session, sdt, user_password)
        
        # Return an error if user not in database
        if result == 0:
            flash("Invalid Login Credentials!", "error")
            return redirect("/login")

        session['sdt'] = sdt
        session['user_password'] = user_password

        return redirect("/")

    return render_template("login.html")


# Create Sign Out Route which we'll create a button for
@auth_views.route("/logout", strict_slashes=False)
@login_required
def logout():
    # We wrap the logout function with @login_required decorator
    # So that only logged in users should be able to 'log out'
    logout_user()
    return redirect("/")

