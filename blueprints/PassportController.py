from flask import Blueprint, request, render_template, redirect, flash
from flask import Flask, session, redirect, url_for, request
from models.UserAccount import get_account_by_cccd_pw
from middleware import auth_middleware

passportCT = Blueprint("passport", __name__)

@passportCT.route("/insertpassport", strict_slashes=False, methods=["GET", "POST"])
@auth_middleware
def register_passport():    
    if request.method == "POST":
        cccd = request.form.get("cccd")
        user_password = request.form.get("password")

        result = get_account_by_cccd_pw(cccd, user_password)
        
        # Return an error if user not in database
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
@passportCT.route("/updatestatus", strict_slashes=False)
def update_status():
    session.clear()
    return redirect("/")


