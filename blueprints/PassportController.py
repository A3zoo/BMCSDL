from flask import Blueprint, request, render_template, redirect, flash, jsonify
from flask import Flask, session, redirect, url_for, request
from models.PassportInfor import update_status_passport_data_by_cccd,create_passport_data as insert_passport, get_all_passport_data
from blueprints.middleware import auth_middleware
from models.PassportInfor  import PassportDataModel

passportCT = Blueprint("passport", __name__)

@passportCT.route("/insert", strict_slashes=False, methods=["POST"])
@auth_middleware
def register_passport():    
    if request.method == "POST":
        # Xử lý giới tính
        gender = 1 if request.form.get("nam") else 0  # 'nam' trả về 1, 'nu' trả về 0
        
        # Gộp địa chỉ thường trú từ tỉnh, quận, huyện
        dia_chi_thuong_tru = ", ".join(
            filter(None, [
                request.form.get("diachinha"),
                request.form.get("quan_label"),
                request.form.get("tinh_label")
            ])
        )

        # Lấy dữ liệu từ form và ánh xạ vào mô hình Pydantic
        data = PassportDataModel(
            HoVaTen=request.form.get("hoten"),
            GioiTinh=gender,
            SinhNgay=request.form.get("ngaysinh"),
            NoiSinh=request.form.get("noisinh_label"),
            SoCCCD=session["cccd"],
            NgayCapCCCD=request.form.get("ngaycap"),
            DanToc=request.form.get("dantoc_label"),
            TonGiao=request.form.get("tongiao_label"),
            SoDienThoai=request.form.get("sdt"),
            DiaChiDangKyThuongTru=dia_chi_thuong_tru,
            DiaChiDangKyTamTru=request.form.get("diachi"),
            NgheNghiep=request.form.get("nghe"),
            CoQuan=request.form.get("ten_co_quan"),
            HoTenCha=request.form.get("ho_ten_cha"),
            NgaySinhCha=request.form.get("ngaysinhcha"),
            HoTenMe=request.form.get("ho_ten_me"),
            NgaySinhMe=request.form.get("ngaysinhme"),
            HoTenVoChong=request.form.get("ho_ten_vo_chong"),
            NgaySinhVoChong=request.form.get("ngaysinhvochong"),
            NoiTiepNhan=request.form.get("coquan_label"),
            NoiDungDeNghi=request.form.get("noidung_de_nghi", None),  # Giá trị mặc định nếu không có
            CoGanChip=request.form.get("co_gan_chip", 0),  # Giá trị mặc định
            DiaChiNopHoSo=request.form.get("diachi_nop_ho_so", None),
            TrangThai=1  # Giá trị mặc định cho trạng thái
        )

        # Chèn dữ liệu vào cơ sở dữ liệu
        passport = insert_passport(data)  
        if passport:
            flash("Thêm hộ chiếu thành công!", "success")
            return render_template('app/html/profile.html', passport=passport)
        
        # Nếu thêm thất bại
        flash("Đã xảy ra lỗi khi thêm hộ chiếu. Vui lòng thử lại.", "error")
        return render_template('app/html/profile.html', data=data)

    # Trường hợp GET hoặc các phương thức khác
    return render_template("login_mh1.html")


@passportCT.route("/updatestatus", methods=["PUT"],strict_slashes=False)
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
    


