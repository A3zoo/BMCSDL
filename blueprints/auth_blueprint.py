from flask import Blueprint, request, render_template, redirect, flash
from flask import session, redirect, url_for, request
from models.UserAccount import get_account_by_cccd_pw

auth_views = Blueprint("auth", __name__)

@auth_views.route("/login", strict_slashes=False, methods=["GET", "POST"])
def login():    
    if request.method == "POST":
        cccd = request.form.get("cccd")
        user_password = request.form.get("password")

        result = get_account_by_cccd_pw(cccd, user_password)
        
        if not result:
            flash("Invalid Login Credentials!", "error")
            return redirect("/login")

        session['cccd'] = cccd
        session['password'] = user_password
        session['vt'] = result.UserType
        # RESIDENT, XT, XD, LT, GS
        if session['vt'] == 'XT':
            return redirect("/")
        elif session['vt'] == 'XD':
            return redirect("/")
        elif session['vt'] == 'LT':
            return redirect("/")
        elif session['vt'] == 'GS':
            return redirect("/")
        return redirect("/")

    return render_template("login.html")


# Create Sign Out Route which we'll create a button for
@auth_views.route("/logout", strict_slashes=False)
def logout():
    session.clear()
    return redirect("/")


