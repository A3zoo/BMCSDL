from flask import Blueprint, request, render_template, redirect, flash
from flask import session, redirect, url_for, request
from models.UserAccount import get_account_by_cccd_pw
from models.PassportInfor import get_all_passport_data, get_passport_data
from models.Audit import get_all_audit
auth_views = Blueprint("auth", __name__)

@auth_views.route("/login", strict_slashes=False, methods=["GET", "POST"])
def login():    
    if request.method == "POST":
        cccd = request.form.get("cccd")
        user_password = request.form.get("password")

        result = get_account_by_cccd_pw(cccd, user_password)
        
        if not result:
            flash("Invalid Login Credentials!", "error")
            return redirect("")
        session['cccd'] = cccd
        session['password'] = user_password
        session['vt'] = result.UserType
        # RESIDENT, XT, XD, LT, GS
        if session['vt'] == 'XT':
            data = get_all_passport_data()
            return render_template("app/html/danh_sach_yeu_cau_cho_xac_thuc_mh4.html", listpassportdata =  data)
        elif session['vt'] == 'XD':
            data = get_all_passport_data()
            return render_template("app/html/danh_sach_yeu_cau_cho_phe_duyet_mh7.html", listpassportdata =  data)
        elif session['vt'] == 'LT':
            data = get_all_passport_data()
            return render_template("app/html/danh_sach_ket_qua_phe_duyet_mh10.html", listpassportdata =  data)
        elif session['vt'] == 'GS':
            data = get_audit_trails_for_passport()
            return render_template('app/html/GS.html', audit_trails = data)
        return render_template("app/html/profile.html", duy =  result)
    return render_template("login.html")

def get_audit_trails_for_passport():
    return get_all_audit()

# Create Sign Out Route which we'll create a button for
@auth_views.route("/logout", strict_slashes=False)
def logout():
    session.clear()
    return redirect("/")


