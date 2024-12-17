from flask import Blueprint, request, render_template, redirect, flash
from flask import Flask, session, redirect, url_for, request
from models.PassportInfor import update_status_passport_data_by_cccd,create_passport_data as insert_passport, get_all_passport_data
from blueprints.middleware import auth_middleware

passportCT = Blueprint("passport", __name__)

@passportCT.route("/insert", strict_slashes=False, methods=["POST"])
@auth_middleware
def register_passport():    
    if request.method == "POST":
        data = request.get_json()  
        passport = insert_passport(data)
        if passport:
            flash("Thêm hộ chiếu thành công!", "success")
            return render_template('app/html/profile.html', passport = passport) 
        flash("Đã xảy ra lỗi khi thêm hộ chiếu. Vui lòng thử lại.", "error")
        return render_template('app/html/nguoi_dang_ky_mh2.html', data = data)
    return render_template("login_mh1.html")


@passportCT.route("/updatestatus", strict_slashes=False)
@auth_middleware
def update_status():
    cccd = request.args.get('cccd')
    aggre = request.args.get('aggre', type=int)
    up_status = 0 if  aggre == 0 else aggre + 1 # type: ignore
    result = update_status_passport_data_by_cccd(cccd, up_status)
    data = get_all_passport_data()
    if result:
        if session['vt'] == 'XT':
            flash("XT thành công!" + result.HoVaTen, "success") # type: ignore
            return render_template("app/html/danh_sach_yeu_cau_cho_xac_thuc_mh4.html", listpassportdata =  data)
        elif session['vt'] == 'XD':
            flash("XD thành công!" + result.HoVaTen, "success") # type: ignore
            return render_template("app/html/danh_sach_yeu_cau_cho_phe_duyet_mh7.html", listpassportdata =  data)
        elif session['vt'] == 'LT':
            flash("LT thành công!" + result.HoVaTen, "success") # type: ignore
            return render_template("app/html/danh_sach_ket_qua_phe_duyet_mh10.html", listpassportdata =  data)
    flash("Đã xảy ra lỗi khi thêm hộ chiếu. Vui lòng thử lại.", "error")
    return render_template('app/html/nguoi_dang_ky_mh2.html', listpassportdata = data)
    


