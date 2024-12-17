from flask import Blueprint, request, render_template, redirect, flash, jsonify
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
    return render_template("login.html")


@passportCT.route("/updatestatus", strict_slashes=False)
def update_status():
    data = request.get_json()

    # Kiểm tra xem dữ liệu có được gửi hay không
    if not data or 'cccd' not in data or 'aggre' not in data:
        return jsonify({"message": "Missing required data"}), 400
    
    str_dir = {
        1 : "đang chờ xác thực",
        2: "Bạn đã xác thực thành công ",
        3: "Bạn đã phê duyệt thành công ",
        4: "Bạn đã từ chối "
    }

    cccd = data['cccd']
    aggre = data['aggre']
    result = update_status_passport_data_by_cccd(cccd, aggre)
    return jsonify({"message": str_dir[result.TrangThai] + str(result.SoCCCD)})
    


