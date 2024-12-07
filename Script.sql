CREATE TABLE UserAccount (
    CCCD VARCHAR2(20) PRIMARY KEY,
    Password VARCHAR2(100) NOT NULL,
    Email VARCHAR2(25) UNIQUE NOT NULL,
    Sdt VARCHAR2(15),
    UserType VARCHAR2(15) -- RESIDENT, XT, XD, LT, GS
);

-- Thêm 10 dữ liệu mẫu vào bảng UserAccount
INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789001', 'hieu2003', 'phuhieua2@gmail.com', '012345678', 'XT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789002', 'minh2023', 'minha2@gmail.com', '0987654321', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789003', 'hoa2001', 'hoa23@gmail.com', '0909090909', 'LT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789004', 'ngoc2002', 'ngoca2@gmail.com', '0912345678', 'XD');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789005', 'thao2004', 'thaobk@gmail.com', '0923456789', 'GS');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789006', 'duc2022', 'ducnguyen@gmail.com', '0934567890', 'XT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789007', 'phong2020', 'phonghoang@gmail.com', '0945678901', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789008', 'hanh2019', 'hanhtrang@gmail.com', '0956789012', 'LT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789009', 'linh2018', 'linhtran@gmail.com', '0967890123', 'XD');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('123456789010', 'huy2017', 'huynguyen@gmail.com', '0978901234', 'GS');

-- Thêm 10 dữ liệu người dùng loại RESIDENT với thông tin thực tế
INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000001', 'nguyenhieu2003', 'nguyenhieu01@gmail.com', '0901234001', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000002', 'trananh2022', 'trananh02@gmail.com', '0901234002', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000003', 'lehoa2001', 'lehoa03@gmail.com', '0901234003', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000004', 'phamthao2020', 'phamthao04@gmail.com', '0901234004', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000005', 'vominh2019', 'vominh05@gmail.com', '0901234005', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000006', 'dinhhung2018', 'dinhhung06@gmail.com', '0901234006', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000007', 'hoangthanh2017', 'hoangthanh07@gmail.com', '0901234007', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000008', 'truongngoc2016', 'truongngoc08@gmail.com', '0901234008', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000009', 'dangbao2015', 'dangbao09@gmail.com', '0901234009', 'RESIDENT');

INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
VALUES ('100000000010', 'ngothao2014', 'ngothao10@gmail.com', '0901234010', 'RESIDENT');

CREATE OR REPLACE FUNCTION HashPassword(p_password VARCHAR2) RETURN VARCHAR2 IS
    v_hashed_password RAW(32);
BEGIN
    -- Sử dụng DBMS_CRYPTO để băm mật khẩu với SHA-256
    v_hashed_password := DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    
    -- Trả về giá trị băm dưới dạng chuỗi HEX
    RETURN RAWTOHEX(v_hashed_password);
END;
/

--Trigger  hashpass rtuoc khi luu  vao database
CREATE OR REPLACE TRIGGER trg_before_insert_update_useraccount
BEFORE INSERT OR UPDATE ON UserAccount
FOR EACH ROW
BEGIN
    -- Kiểm tra nếu mật khẩu đã được băm rồi thì không băm lại
    IF :NEW.Password IS NOT NULL AND LENGTH(:NEW.Password) < 64 THEN
        :NEW.Password := HashPassword(:NEW.Password);
    END IF;
END;
/


--Ham check Dang nhap
CREATE OR REPLACE FUNCTION CheckLoginStatus(
    p_CCCD VARCHAR2,
    p_password VARCHAR2
) RETURN VARCHAR2 IS
    v_stored_password VARCHAR2(100);
BEGIN
    -- Lấy mật khẩu đã băm từ cơ sở dữ liệu dựa trên username
    SELECT Password INTO v_stored_password
    FROM UserAccount
    WHERE CCCD = p_CCCD;

    -- So sánh mật khẩu nhập vào (sau khi băm) với mật khẩu trong cơ sở dữ liệu
    IF v_stored_password = HashPassword(p_password) THEN
        RETURN 'TRUE';
    ELSE
        RETURN 'FALSE';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'FALSE';
END;
/

DECLARE
    v_status VARCHAR2(20);
BEGIN
    v_status := CheckLoginStatus('123456789062', 'pass1234');
    DBMS_OUTPUT.PUT_LINE('Login Status: ' || v_status);
END;



--Tao User check trung lap CCCD, Email
CREATE OR REPLACE FUNCTION CreateUserAccount(
    p_CCCD VARCHAR2,
    p_password VARCHAR2,
    p_email VARCHAR2,
    p_sdt VARCHAR2,
    p_usertype VARCHAR2
) RETURN VARCHAR2 IS
    v_count INTEGER;
BEGIN
    -- Kiểm tra trùng lặp CCCD
    SELECT COUNT(*) INTO v_count FROM UserAccount WHERE CCCD = p_CCCD;
    IF v_count > 0 THEN
        RETURN 'CCCD đã tồn tại trong hệ thống.';
    END IF;

    -- Kiểm tra trùng lặp Email
    SELECT COUNT(*) INTO v_count FROM UserAccount WHERE Email = p_email;
    IF v_count > 0 THEN
        RETURN 'Email đã tồn tại trong hệ thống.';
    END IF;

    -- Nếu không có trùng lặp, tiến hành thêm tài khoản mới với mật khẩu đã băm
    INSERT INTO UserAccount (CCCD, Password, Email, Sdt, UserType)
    VALUES (p_CCCD, HashPassword(p_password), p_email, p_sdt, p_usertype);

    RETURN 'Tài khoản đã được tạo thành công.';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/


--Profile
CREATE PROFILE resident_account LIMIT 
    SESSIONS_PER_USER 5 
    CONNECT_TIME 3 
    PASSWORD_LIFE_TIME 0.003472 -- 5 phút
    PASSWORD_REUSE_TIME 2 
    PASSWORD_REUSE_MAX 3 
    FAILED_LOGIN_ATTEMPTS 3;
    
CREATE PROFILE admin_account
LIMIT 
    FAILED_LOGIN_ATTEMPTS 5              -- Giới hạn 5 lần đăng nhập sai
    PASSWORD_LIFE_TIME 30               -- Mật khẩu hết hạn sau 30 ngày
    PASSWORD_REUSE_TIME 90              -- Không thể tái sử dụng mật khẩu trong 90 ngày
    PASSWORD_REUSE_MAX 3                -- Phải đổi ít nhất 3 mật khẩu trước khi sử dụng lại
    PASSWORD_LOCK_TIME 1/24             -- Khóa tài khoản trong 1 giờ nếu đăng nhập sai nhiều lần
    PASSWORD_GRACE_TIME 7               -- Cảnh báo người dùng 7 ngày trước khi mật khẩu hết hạn
    SESSIONS_PER_USER 2;                -- Giới hạn mỗi người dùng 2 phiên đăng nhập.




CREATE ROLE XT_ROLE;
GRANT SELECT, UPDATE ON sec_manager.PassportData TO XT_ROLE;
GRANT SELECT ON sec_manager.ResidentData TO XT_ROLE;


CREATE ROLE XD_ROLE;
GRANT SELECT, UPDATE ON sec_manager.PassportData TO XD_ROLE;


CREATE ROLE LT_ROLE;
GRANT SELECT ON sec_manager.PassportData_Limited TO LT_ROLE;

CREATE ROLE GS_ROLE;
GRANT SELECT ON sec_manager.PassportData TO GS_ROLE;
GRANT SELECT ON sec_manager.ResidentData TO GS_ROLE;
GRANT SELECT ON sec_manager.PassportData_Limited TO GS_ROLE;

CREATE ROLE RESIDENT_ROLE;
GRANT SELECT ON sec_manager.ResidentData_Limited TO RESIDENT_ROLE;
GRANT SELECT ON sec_manager.PassportData_Limited TO RESIDENT_ROLE;

--view xem mỗi resident 
CREATE OR REPLACE VIEW sec_manager.ResidentData_Limited AS
SELECT *
FROM sec_manager.ResidentData
WHERE SoCCCD = SYS_CONTEXT('USERENV', 'SESSION_USER');

--View xem form dang ki 
CREATE OR REPLACE VIEW sec_manager.PassportData_Limited AS
SELECT *
FROM sec_manager.PassportData
WHERE SoCCCD = SYS_CONTEXT('USERENV', 'SESSION_USER');

 -- View LT
CREATE OR REPLACE VIEW sec_manager.PassportData_Limited AS
SELECT SoCCCD, TRANGTHAI
FROM NATIONAL_DATA_CENTER.PassportData;

--Them useraccount va user trong dtb
CREATE OR REPLACE FUNCTION CreateUserAndDBAccount(
    p_CCCD VARCHAR2,
    p_password VARCHAR2,
    p_email VARCHAR2,
    p_sdt VARCHAR2,
    p_usertype VARCHAR2
) RETURN VARCHAR2 IS
    v_result VARCHAR2(4000);
BEGIN
    -- Gọi hàm CreateUserAccount để thêm user vào bảng UserAccount
    v_result := CreateUserAccount(p_CCCD, p_password, p_email, p_sdt, p_usertype);

    -- Kiểm tra kết quả từ hàm CreateUserAccount
    IF v_result != 'Tài khoản đã được tạo thành công.' THEN
        RETURN v_result; -- Trả về thông báo lỗi từ hàm CreateUserAccount nếu có
    END IF;

    -- Nếu tài khoản được tạo thành công, tiếp tục tạo user trong cơ sở dữ liệu
    EXECUTE IMMEDIATE 'CREATE USER "' || p_CCCD || '" IDENTIFIED BY "' || p_password || '"';

    -- Cấp quyền tối thiểu cho user mới tạo
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO "' || p_CCCD || '"';

    -- Gán quyền và profile theo loại người dùng
    IF p_usertype = 'RESIDENT' THEN
        EXECUTE IMMEDIATE 'GRANT RESIDENT_ROLE TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT, UPDATE ON sec_manager.PASSPORTDATA TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT ON sec_manager.RESIDENTDATA TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'ALTER USER "' || p_CCCD || '" PROFILE resident_account';
    ELSIF p_usertype = 'LT' THEN
        EXECUTE IMMEDIATE 'GRANT LT_ROLE TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT ON sec_manager.PASSPORTDATA_Limited TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'ALTER USER "' || p_CCCD || '" PROFILE admin_account';
    ELSIF p_usertype = 'XT' THEN
        EXECUTE IMMEDIATE 'GRANT XT_ROLE TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT, UPDATE ON sec_manager.PASSPORTDATA TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT ON sec_manager.RESIDENTDATA TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'ALTER USER "' || p_CCCD || '" PROFILE admin_account';
    ELSIF p_usertype = 'XD' THEN
        EXECUTE IMMEDIATE 'GRANT XD_ROLE TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT, UPDATE ON sec_manager.PASSPORTDATA TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'ALTER USER "' || p_CCCD || '" PROFILE admin_account';
    ELSIF p_usertype = 'GS' THEN
        EXECUTE IMMEDIATE 'GRANT GS_ROLE TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT SELECT ANY DICTIONARY TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'GRANT AUDIT_VIEWER TO "' || p_CCCD || '"';
        --EXECUTE IMMEDIATE 'ALTER USER "' || p_CCCD || '" PROFILE admin_account';
    END IF;

    RETURN 'Tài khoản và user trong cơ sở dữ liệu đã được tạo thành công.';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/



DECLARE
    v_result VARCHAR2(4000);
BEGIN
    v_result := CreateUserAndDBAccount('1234567880', 'pass1234', 'xdd@example.com', '0912345678', 'XD');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

DECLARE
    v_result VARCHAR2(4000);
BEGIN
    -- User type 'RESIDENT'
    v_result := CreateUserAndDBAccount('123456781', 'pass1234', 'resident@example.com', '0912345671', 'RESIDENT');
    DBMS_OUTPUT.PUT_LINE(v_result);

    -- User type 'LT'
    v_result := CreateUserAndDBAccount('123456782', 'pass1234', 'lt@example.com', '0912345672', 'LT');
    DBMS_OUTPUT.PUT_LINE(v_result);

    -- User type 'XT'
    v_result := CreateUserAndDBAccount('123456783', 'pass1234', 'xt@example.com', '0912345673', 'XT');
    DBMS_OUTPUT.PUT_LINE(v_result);

    -- User type 'XD'
    v_result := CreateUserAndDBAccount('123456784', 'pass1234', 'xd@example.com', '0912345674', 'XD');
    DBMS_OUTPUT.PUT_LINE(v_result);

    -- User type 'GS'
    v_result := CreateUserAndDBAccount('123456785', 'pass1234', 'gs@example.com', '0912345675', 'GS');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/


CREATE TABLE PASSPORTDATA (
    Id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    HoVaTen VARCHAR2(100) NOT NULL,
    GioiTinh NUMBER(1),
    SinhNgay DATE,
    NoiSinh VARCHAR2(100),
    SoCCCD VARCHAR2(20) NOT NULL UNIQUE,
    NgayCapCCCD DATE,
    DanToc VARCHAR2(50),
    TonGiao VARCHAR2(50),
    SoDienThoai VARCHAR2(15),
    DiaChiDangKyThuongTru VARCHAR2(200),
    DiaChiDangKyTamTru VARCHAR2(200),
    NgheNghiep VARCHAR2(100),
    CoQuan VARCHAR2(100),
    HoTenCha VARCHAR2(100),
    NgaySinhCha DATE,
    HoTenMe VARCHAR2(100),
    NgaySinhMe DATE,
    HoTenVoChong VARCHAR2(100),
    NgaySinhVoChong DATE,
    NoiDungDeNghi VARCHAR2(500),
    CoGanChip NUMBER(1),
    NoiTiepNhan VARCHAR2(100),
    DiaChiNopHoSo VARCHAR2(100),
    TrangThai INT, --1,2,3,4
    CONSTRAINT fk_user FOREIGN KEY (SoCCCD) REFERENCES UserAccount(CCCD) ON DELETE CASCADE
);


INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Nguyễn Văn An', 1, TO_DATE('1990-01-15', 'YYYY-MM-DD'), 'Hà Nội', '123456789002', TO_DATE('2015-06-01', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345678', 'Hà Nội', 'Hà Nội', 'Kỹ sư', 'Công ty ABC', 'Nguyễn Văn Bình', TO_DATE('1960-05-15', 'YYYY-MM-DD'), 'Trần Thị Cúc', TO_DATE('1962-07-20', 'YYYY-MM-DD'), NULL, NULL, 'Xin cấp hộ chiếu phổ thông', 1, 'Phòng Tiếp dân', 'Hà Nội', 1);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Lê Thị Hoa', 0, TO_DATE('1992-03-22', 'YYYY-MM-DD'), 'Đà Nẵng', '123456789007', TO_DATE('2018-01-10', 'YYYY-MM-DD'), 'Kinh', 'Không', '0987654321', 'Đà Nẵng', 'Đà Nẵng', 'Giáo viên', 'Trường THPT A', 'Lê Văn Minh', TO_DATE('1965-09-18', 'YYYY-MM-DD'), 'Nguyễn Thị Lý', TO_DATE('1970-01-25', 'YYYY-MM-DD'), NULL, NULL, 'Cấp lại hộ chiếu bị mất', 1, 'Phòng Hộ chiếu', 'Đà Nẵng', 2);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Phạm Quốc Bảo', 1, TO_DATE('1985-08-10', 'YYYY-MM-DD'), 'TP. Hồ Chí Minh', '100000000001', TO_DATE('2020-05-18', 'YYYY-MM-DD'), 'Kinh', 'Không', '0913456789', 'TP. Hồ Chí Minh', 'TP. Hồ Chí Minh', 'Bác sĩ', 'Bệnh viện B', 'Phạm Văn Hải', TO_DATE('1960-03-10', 'YYYY-MM-DD'), 'Trần Thị Lan', TO_DATE('1963-07-12', 'YYYY-MM-DD'), 'Nguyễn Thị Hạnh', TO_DATE('1987-12-25', 'YYYY-MM-DD'), 'Đề nghị cấp hộ chiếu mới', 0, 'Phòng Xuất nhập cảnh', 'TP. Hồ Chí Minh', 1);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Trần Minh Tú', 1, TO_DATE('1995-09-19', 'YYYY-MM-DD'), 'Hải Phòng', '100000000002', TO_DATE('2019-12-20', 'YYYY-MM-DD'), 'Kinh', 'Không', '0935678901', 'Hải Phòng', 'Hải Phòng', 'Nhân viên', 'Công ty X', 'Trần Văn Dũng', TO_DATE('1968-02-15', 'YYYY-MM-DD'), 'Nguyễn Thị Ngọc', TO_DATE('1972-05-10', 'YYYY-MM-DD'), NULL, NULL, 'Gia hạn hộ chiếu', 1, 'Phòng Quản lý Xuất nhập cảnh', 'Hải Phòng', 3);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Hoàng Thị Thanh', 0, TO_DATE('1988-02-05', 'YYYY-MM-DD'), 'Huế', '100000000003', TO_DATE('2022-08-15', 'YYYY-MM-DD'), 'Kinh', 'Không', '0976543210', 'Huế', 'Huế', 'Sinh viên', 'Đại học Huế', 'Hoàng Văn Hùng', TO_DATE('1970-03-08', 'YYYY-MM-DD'), 'Phạm Thị Mai', TO_DATE('1974-11-25', 'YYYY-MM-DD'), NULL, NULL, 'Xin cấp hộ chiếu lần đầu', 1, 'Phòng Hộ chiếu', 'Huế', 2);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Võ Văn Lâm', 1, TO_DATE('1993-06-30', 'YYYY-MM-DD'), 'Cần Thơ', '100000000004', TO_DATE('2021-03-20', 'YYYY-MM-DD'), 'Kinh', 'Không', '0909871234', 'Cần Thơ', 'Cần Thơ', 'Kỹ sư', 'Công ty C', 'Võ Văn Hưng', TO_DATE('1965-10-15', 'YYYY-MM-DD'), 'Nguyễn Thị Yến', TO_DATE('1968-04-20', 'YYYY-MM-DD'), 'Lê Thị Ngân', TO_DATE('1995-02-14', 'YYYY-MM-DD'), 'Đề nghị cấp hộ chiếu đi công tác', 0, 'Phòng Xuất nhập cảnh', 'Cần Thơ', 4);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Nguyễn Thị Mai', 0, TO_DATE('1990-11-11', 'YYYY-MM-DD'), 'Hà Nội', '100000000005', TO_DATE('2017-02-12', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345678', 'Hà Nội', 'Hà Nội', 'Giảng viên', 'Trường Đại học X', 'Nguyễn Văn Toàn', TO_DATE('1960-12-05', 'YYYY-MM-DD'), 'Trần Thị Vân', TO_DATE('1965-07-18', 'YYYY-MM-DD'), NULL, NULL, 'Đề nghị cấp hộ chiếu cho đi du lịch', 1, 'Phòng Xuất nhập cảnh', 'Hà Nội', 3);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Trương Minh Tâm', 1, TO_DATE('1984-07-25', 'YYYY-MM-DD'), 'Hà Nội', '100000000006', TO_DATE('2016-09-12', 'YYYY-MM-DD'), 'Kinh', 'Không', '0987654321', 'Hà Nội', 'Hà Nội', 'Lập trình viên', 'Công ty Y', 'Trương Văn Lộc', TO_DATE('1962-08-18', 'YYYY-MM-DD'), 'Nguyễn Thị Lan', TO_DATE('1965-01-11', 'YYYY-MM-DD'), NULL, NULL, 'Cấp lại hộ chiếu', 1, 'Phòng Hộ chiếu', 'Hà Nội', 1);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Bùi Thị Hồng', 0, TO_DATE('1996-03-14', 'YYYY-MM-DD'), 'Hải Dương', '100000000007', TO_DATE('2020-10-15', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345678', 'Hải Dương', 'Hải Dương', 'Họa sĩ', 'Công ty Z', 'Bùi Minh Tuấn', TO_DATE('1965-04-28', 'YYYY-MM-DD'), 'Nguyễn Thị Hà', TO_DATE('1970-09-03', 'YYYY-MM-DD'), NULL, NULL, 'Cấp hộ chiếu lần đầu', 0, 'Phòng Quản lý Xuất nhập cảnh', 'Hải Dương', 2);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Lê Quang Minh', 1, TO_DATE('1980-12-05', 'YYYY-MM-DD'), 'Bình Dương', '100000000008', TO_DATE('2017-05-20', 'YYYY-MM-DD'), 'Kinh', 'Không', '0919876543', 'Bình Dương', 'Bình Dương', 'Chuyên gia IT', 'Công ty ABC', 'Lê Văn Mạnh', TO_DATE('1955-08-14', 'YYYY-MM-DD'), 'Trần Thị Hoài', TO_DATE('1960-03-22', 'YYYY-MM-DD'), NULL, NULL, 'Cấp hộ chiếu công tác', 1, 'Phòng Xuất nhập cảnh', 'Bình Dương', 3);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Phan Thị Lan', 0, TO_DATE('1991-10-19', 'YYYY-MM-DD'), 'Nghệ An', '100000000009', TO_DATE('2019-01-07', 'YYYY-MM-DD'), 'Kinh', 'Không', '0938765432', 'Nghệ An', 'Nghệ An', 'Giáo viên', 'Trường Đại học T', 'Phan Văn Quân', TO_DATE('1960-02-22', 'YYYY-MM-DD'), 'Nguyễn Thị Lan', TO_DATE('1963-11-14', 'YYYY-MM-DD'), NULL, NULL, 'Đề nghị cấp hộ chiếu', 0, 'Phòng Tiếp dân', 'Nghệ An', 4);

INSERT INTO PASSPORTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong,
    NoiDungDeNghi, CoGanChip, NoiTiepNhan, DiaChiNopHoSo, TrangThai
) VALUES
('Trần Bảo Lâm', 1, TO_DATE('1987-11-02', 'YYYY-MM-DD'), 'Đà Nẵng', '100000000010', TO_DATE('2021-11-03', 'YYYY-MM-DD'), 'Kinh', 'Không', '0902345678', 'Đà Nẵng', 'Đà Nẵng', 'Nhân viên', 'Công ty Q', 'Trần Văn Bình', TO_DATE('1970-01-12', 'YYYY-MM-DD'), 'Phạm Thị Mai', TO_DATE('1973-04-08', 'YYYY-MM-DD'), NULL, NULL, 'Cấp hộ chiếu mới', 1, 'Phòng Xuất nhập cảnh', 'Đà Nẵng', 1);




CREATE TABLE RESIDENTDATA (
    Id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    HoVaTen VARCHAR2(100) NOT NULL,
    GioiTinh NUMBER(1),
    SinhNgay DATE,
    NoiSinh VARCHAR2(100),
    SoCCCD VARCHAR2(20) NOT NULL UNIQUE,
    NgayCapCCCD DATE,
    DanToc VARCHAR2(50),
    TonGiao VARCHAR2(50),
    SoDienThoai VARCHAR2(15),
    DiaChiDangKyThuongTru VARCHAR2(200),
    DiaChiDangKyTamTru VARCHAR2(200),
    NgheNghiep VARCHAR2(100),
    CoQuan VARCHAR2(100),
    HoTenCha VARCHAR2(100),
    NgaySinhCha DATE,
    HoTenMe VARCHAR2(100),
    NgaySinhMe DATE,
    HoTenVoChong VARCHAR2(100),
    NgaySinhVoChong DATE
);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Nguyễn Văn An', 1, TO_DATE('1990-01-15', 'YYYY-MM-DD'), 'Hà Nội', '123456789002', TO_DATE('2015-06-01', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345678', 'Hà Nội', 'Hà Nội', 'Kỹ sư', 'Công ty ABC', 'Nguyễn Văn Bình', TO_DATE('1960-05-15', 'YYYY-MM-DD'), 'Trần Thị Cúc', TO_DATE('1962-07-20', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Lê Thị Hoa', 0, TO_DATE('1992-03-22', 'YYYY-MM-DD'), 'Đà Nẵng', '123456789007', TO_DATE('2018-01-10', 'YYYY-MM-DD'), 'Kinh', 'Không', '0987654321', 'Đà Nẵng', 'Đà Nẵng', 'Giáo viên', 'Trường THPT A', 'Lê Văn Minh', TO_DATE('1965-09-18', 'YYYY-MM-DD'), 'Nguyễn Thị Lý', TO_DATE('1970-01-25', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Phạm Quốc Bảo', 1, TO_DATE('1985-08-10', 'YYYY-MM-DD'), 'TP. Hồ Chí Minh', '100000000001', TO_DATE('2020-05-18', 'YYYY-MM-DD'), 'Kinh', 'Không', '0913456789', 'TP. Hồ Chí Minh', 'TP. Hồ Chí Minh', 'Bác sĩ', 'Bệnh viện B', 'Phạm Văn Hải', TO_DATE('1960-03-10', 'YYYY-MM-DD'), 'Trần Thị Lan', TO_DATE('1963-07-12', 'YYYY-MM-DD'), 'Nguyễn Thị Hạnh', TO_DATE('1987-12-25', 'YYYY-MM-DD'));

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Trần Minh Tú', 1, TO_DATE('1995-09-19', 'YYYY-MM-DD'), 'Hải Phòng', '100000000002', TO_DATE('2019-12-20', 'YYYY-MM-DD'), 'Kinh', 'Không', '0935678901', 'Hải Phòng', 'Hải Phòng', 'Nhân viên', 'Công ty X', 'Trần Văn Dũng', TO_DATE('1968-02-15', 'YYYY-MM-DD'), 'Nguyễn Thị Ngọc', TO_DATE('1972-05-10', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Hoàng Thị Thanh', 0, TO_DATE('1988-02-05', 'YYYY-MM-DD'), 'Huế', '100000000003', TO_DATE('2022-08-15', 'YYYY-MM-DD'), 'Kinh', 'Không', '0976543210', 'Huế', 'Huế', 'Sinh viên', 'Đại học Huế', 'Hoàng Văn Hùng', TO_DATE('1970-03-08', 'YYYY-MM-DD'), 'Phạm Thị Mai', TO_DATE('1974-11-25', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Võ Văn Lâm', 1, TO_DATE('1993-06-30', 'YYYY-MM-DD'), 'Cần Thơ', '100000000004', TO_DATE('2021-03-20', 'YYYY-MM-DD'), 'Kinh', 'Không', '0909871234', 'Cần Thơ', 'Cần Thơ', 'Kỹ sư', 'Công ty C', 'Võ Văn Hưng', TO_DATE('1965-10-15', 'YYYY-MM-DD'), 'Nguyễn Thị Yến', TO_DATE('1968-04-20', 'YYYY-MM-DD'), 'Lê Thị Ngân', TO_DATE('1995-02-14', 'YYYY-MM-DD'));

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Nguyễn Thị Mai', 0, TO_DATE('1990-11-11', 'YYYY-MM-DD'), 'Hà Nội', '100000000005', TO_DATE('2018-11-11', 'YYYY-MM-DD'), 'Kinh', 'Không', '0945123456', 'Hà Nội', 'Hà Nội', 'Nhân viên', 'Ngân hàng A', 'Nguyễn Văn Cường', TO_DATE('1960-05-15', 'YYYY-MM-DD'), 'Trần Thị Nhàn', TO_DATE('1963-03-20', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Lê Văn Khánh', 1, TO_DATE('1983-07-25', 'YYYY-MM-DD'), 'Đà Nẵng', '100000000006', TO_DATE('2017-04-15', 'YYYY-MM-DD'), 'Kinh', 'Không', '0939876543', 'Đà Nẵng', 'Đà Nẵng', 'Kỹ sư', 'Công ty E', 'Lê Văn Sơn', TO_DATE('1965-03-01', 'YYYY-MM-DD'), 'Nguyễn Thị Hoa', TO_DATE('1968-08-10', 'YYYY-MM-DD'), 'Trần Thị Xuân', TO_DATE('1986-09-09', 'YYYY-MM-DD'));

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Trần Thị Lệ', 0, TO_DATE('1987-12-25', 'YYYY-MM-DD'), 'Nghệ An', '100000000007', TO_DATE('2015-03-10', 'YYYY-MM-DD'), 'Kinh', 'Không', '0901234567', 'Nghệ An', 'Nghệ An', 'Giảng viên', 'Trường Đại học A', 'Trần Văn Hoàng', TO_DATE('1962-01-20', 'YYYY-MM-DD'), 'Nguyễn Thị Lan', TO_DATE('1965-09-05', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Nguyễn Văn Tuấn', 1, TO_DATE('1994-05-10', 'YYYY-MM-DD'), 'Quảng Bình', '100000000008', TO_DATE('2016-07-19', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345678', 'Quảng Bình', 'Quảng Bình', 'Bác sĩ', 'Bệnh viện X', 'Nguyễn Văn Dũng', TO_DATE('1965-11-15', 'YYYY-MM-DD'), 'Trần Thị Mai', TO_DATE('1970-03-10', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Lê Thị Tươi', 0, TO_DATE('1985-03-18', 'YYYY-MM-DD'), 'Thanh Hóa', '100000000009', TO_DATE('2017-09-14', 'YYYY-MM-DD'), 'Kinh', 'Không', '0908765432', 'Thanh Hóa', 'Thanh Hóa', 'Giáo viên', 'Trường THPT B', 'Lê Văn Bình', TO_DATE('1965-07-10', 'YYYY-MM-DD'), 'Nguyễn Thị Hoa', TO_DATE('1970-02-22', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Vũ Minh Duy', 1, TO_DATE('1992-10-05', 'YYYY-MM-DD'), 'Vĩnh Phúc', '100000000010', TO_DATE('2018-11-02', 'YYYY-MM-DD'), 'Kinh', 'Không', '0935432109', 'Vĩnh Phúc', 'Vĩnh Phúc', 'Kỹ sư', 'Công ty Z', 'Vũ Văn Bình', TO_DATE('1965-12-01', 'YYYY-MM-DD'), 'Nguyễn Thị Lan', TO_DATE('1970-08-30', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Nguyễn Minh Anh', 1, TO_DATE('1988-02-10', 'YYYY-MM-DD'), 'Bắc Giang', '100000000011', TO_DATE('2020-07-11', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345678', 'Bắc Giang', 'Bắc Giang', 'Kỹ sư', 'Công ty A', 'Nguyễn Văn Hoàng', TO_DATE('1960-10-15', 'YYYY-MM-DD'), 'Trần Thị Lan', TO_DATE('1965-06-05', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Lê Quang Duy', 1, TO_DATE('1985-07-25', 'YYYY-MM-DD'), 'Quảng Ngãi', '100000000012', TO_DATE('2019-06-18', 'YYYY-MM-DD'), 'Kinh', 'Không', '0901234569', 'Quảng Ngãi', 'Quảng Ngãi', 'Giáo viên', 'Trường THPT C', 'Lê Văn Dũng', TO_DATE('1960-12-20', 'YYYY-MM-DD'), 'Nguyễn Thị Lan', TO_DATE('1965-04-15', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Trần Thị Mai', 0, TO_DATE('1991-11-14', 'YYYY-MM-DD'), 'Bình Dương', '100000000013', TO_DATE('2018-12-05', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345670', 'Bình Dương', 'Bình Dương', 'Bác sĩ', 'Bệnh viện D', 'Trần Văn Minh', TO_DATE('1962-05-10', 'YYYY-MM-DD'), 'Nguyễn Thị Thu', TO_DATE('1965-08-22', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Nguyễn Hoàng Nam', 1, TO_DATE('1990-08-30', 'YYYY-MM-DD'), 'Hà Nội', '100000000014', TO_DATE('2019-03-15', 'YYYY-MM-DD'), 'Kinh', 'Không', '0907654321', 'Hà Nội', 'Hà Nội', 'Kỹ sư', 'Công ty B', 'Nguyễn Văn Minh', TO_DATE('1965-04-10', 'YYYY-MM-DD'), 'Trần Thị Lan', TO_DATE('1970-01-15', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Phan Minh Thiện', 1, TO_DATE('1982-05-19', 'YYYY-MM-DD'), 'Hải Dương', '100000000015', TO_DATE('2018-08-01', 'YYYY-MM-DD'), 'Kinh', 'Không', '0908765430', 'Hải Dương', 'Hải Dương', 'Giáo viên', 'Trường Đại học B', 'Phan Văn Minh', TO_DATE('1960-06-18', 'YYYY-MM-DD'), 'Nguyễn Thị Hoa', TO_DATE('1965-10-05', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Vũ Thị Minh', 0, TO_DATE('1995-02-22', 'YYYY-MM-DD'), 'Quảng Nam', '100000000016', TO_DATE('2021-04-10', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345679', 'Quảng Nam', 'Quảng Nam', 'Kỹ sư', 'Công ty D', 'Vũ Văn Tấn', TO_DATE('1965-11-10', 'YYYY-MM-DD'), 'Trần Thị Lý', TO_DATE('1970-01-25', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Lê Đình Khôi', 1, TO_DATE('1992-11-11', 'YYYY-MM-DD'), 'Cà Mau', '100000000017', TO_DATE('2017-09-15', 'YYYY-MM-DD'), 'Kinh', 'Không', '0905678901', 'Cà Mau', 'Cà Mau', 'Nhân viên', 'Công ty E', 'Lê Văn Thành', TO_DATE('1963-04-21', 'YYYY-MM-DD'), 'Nguyễn Thị Hoài', TO_DATE('1965-07-30', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Nguyễn Văn Quân', 1, TO_DATE('1993-04-15', 'YYYY-MM-DD'), 'Bắc Ninh', '100000000018', TO_DATE('2020-11-02', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345670', 'Bắc Ninh', 'Bắc Ninh', 'Bác sĩ', 'Bệnh viện X', 'Nguyễn Văn Dũng', TO_DATE('1960-02-25', 'YYYY-MM-DD'), 'Trần Thị Hoàng', TO_DATE('1965-10-17', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Đoàn Minh Hải', 1, TO_DATE('1989-01-22', 'YYYY-MM-DD'), 'Nam Định', '100000000019', TO_DATE('2016-05-03', 'YYYY-MM-DD'), 'Kinh', 'Không', '0904321098', 'Nam Định', 'Nam Định', 'Giáo viên', 'Trường C', 'Đoàn Văn Khôi', TO_DATE('1965-07-30', 'YYYY-MM-DD'), 'Nguyễn Thị Thanh', TO_DATE('1970-12-10', 'YYYY-MM-DD'), NULL, NULL);

INSERT INTO RESIDENTDATA (
    HoVaTen, GioiTinh, SinhNgay, NoiSinh, SoCCCD, NgayCapCCCD, DanToc, TonGiao,
    SoDienThoai, DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan,
    HoTenCha, NgaySinhCha, HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
) VALUES
('Trần Quang Duy', 1, TO_DATE('1995-10-30', 'YYYY-MM-DD'), 'Thái Bình', '100000000020', TO_DATE('2021-01-12', 'YYYY-MM-DD'), 'Kinh', 'Không', '0912345680', 'Thái Bình', 'Thái Bình', 'Bác sĩ', 'Bệnh viện Y', 'Trần Quang Minh', TO_DATE('1962-04-10', 'YYYY-MM-DD'), 'Nguyễn Thị Lan', TO_DATE('1965-12-05', 'YYYY-MM-DD'), NULL, NULL);


--ham sosanh 
CREATE OR REPLACE FUNCTION CheckInfo(
    p_SoCCCD VARCHAR2
) RETURN VARCHAR2 IS
    -- Khai báo các biến cho các trường của PASSPORTDATA
    v_passport_HoVaTen VARCHAR2(100);
    v_passport_GioiTinh NUMBER(1);
    v_passport_SinhNgay DATE;
    v_passport_NoiSinh VARCHAR2(100);
    v_passport_NgayCapCCCD DATE;
    v_passport_DanToc VARCHAR2(50);
    v_passport_TonGiao VARCHAR2(50);
    v_passport_SoDienThoai VARCHAR2(15);
    v_passport_DiaChiThuongTru VARCHAR2(200);
    v_passport_DiaChiTamTru VARCHAR2(200);
    v_passport_NgheNghiep VARCHAR2(100);
    v_passport_CoQuan VARCHAR2(100);
    v_passport_HoTenCha VARCHAR2(100);
    v_passport_NgaySinhCha DATE;
    v_passport_HoTenMe VARCHAR2(100);
    v_passport_NgaySinhMe DATE;
    v_passport_HoTenVoChong VARCHAR2(100);
    v_passport_NgaySinhVoChong DATE;

    -- Khai báo các biến cho các trường của RESIDENTDATA
    v_RESIDENTDATA_HoVaTen VARCHAR2(100);
    v_RESIDENTDATA_GioiTinh NUMBER(1);
    v_RESIDENTDATA_SinhNgay DATE;
    v_RESIDENTDATA_NoiSinh VARCHAR2(100);
    v_RESIDENTDATA_NgayCapCCCD DATE;
    v_RESIDENTDATA_DanToc VARCHAR2(50);
    v_RESIDENTDATA_TonGiao VARCHAR2(50);
    v_RESIDENTDATA_SoDienThoai VARCHAR2(15);
    v_RESIDENTDATA_DiaChiThuongTru VARCHAR2(200);
    v_RESIDENTDATA_DiaChiTamTru VARCHAR2(200);
    v_RESIDENTDATA_NgheNghiep VARCHAR2(100);
    v_RESIDENTDATA_CoQuan VARCHAR2(100);
    v_RESIDENTDATA_HoTenCha VARCHAR2(100);
    v_RESIDENTDATA_NgaySinhCha DATE;
    v_RESIDENTDATA_HoTenMe VARCHAR2(100);
    v_RESIDENTDATA_NgaySinhMe DATE;
    v_RESIDENTDATA_HoTenVoChong VARCHAR2(100);
    v_RESIDENTDATA_NgaySinhVoChong DATE;

    v_mismatch VARCHAR2(1000) := '';
BEGIN
    -- Lấy thông tin từ bảng PASSPORTDATA
    SELECT HoVaTen, GioiTinh, SinhNgay, NoiSinh, NgayCapCCCD, DanToc, TonGiao, SoDienThoai,
           DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan, HoTenCha, NgaySinhCha,
           HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
    INTO v_passport_HoVaTen, v_passport_GioiTinh, v_passport_SinhNgay, v_passport_NoiSinh, 
         v_passport_NgayCapCCCD, v_passport_DanToc, v_passport_TonGiao, v_passport_SoDienThoai, 
         v_passport_DiaChiThuongTru, v_passport_DiaChiTamTru, v_passport_NgheNghiep, 
         v_passport_CoQuan, v_passport_HoTenCha, v_passport_NgaySinhCha, 
         v_passport_HoTenMe, v_passport_NgaySinhMe, v_passport_HoTenVoChong, 
         v_passport_NgaySinhVoChong
    FROM PASSPORTDATA
    WHERE SoCCCD = p_SoCCCD;

    -- Lấy thông tin từ bảng RESIDENTDATA
    SELECT HoVaTen, GioiTinh, SinhNgay, NoiSinh, NgayCapCCCD, DanToc, TonGiao, SoDienThoai,
           DiaChiDangKyThuongTru, DiaChiDangKyTamTru, NgheNghiep, CoQuan, HoTenCha, NgaySinhCha,
           HoTenMe, NgaySinhMe, HoTenVoChong, NgaySinhVoChong
    INTO v_RESIDENTDATA_HoVaTen, v_RESIDENTDATA_GioiTinh, v_RESIDENTDATA_SinhNgay, v_RESIDENTDATA_NoiSinh, 
         v_RESIDENTDATA_NgayCapCCCD, v_RESIDENTDATA_DanToc, v_RESIDENTDATA_TonGiao, v_RESIDENTDATA_SoDienThoai, 
         v_RESIDENTDATA_DiaChiThuongTru, v_RESIDENTDATA_DiaChiTamTru, v_RESIDENTDATA_NgheNghiep, 
         v_RESIDENTDATA_CoQuan, v_RESIDENTDATA_HoTenCha, v_RESIDENTDATA_NgaySinhCha, 
         v_RESIDENTDATA_HoTenMe, v_RESIDENTDATA_NgaySinhMe, v_RESIDENTDATA_HoTenVoChong, 
         v_RESIDENTDATA_NgaySinhVoChong
    FROM RESIDENTDATA
    WHERE SoCCCD = p_SoCCCD;

    -- So sánh từng trường và thêm vào danh sách các trường không khớp nếu có
    IF v_passport_HoVaTen != v_RESIDENTDATA_HoVaTen THEN
        v_mismatch := v_mismatch || 'HoVaTen, ';
    END IF;
    IF v_passport_GioiTinh != v_RESIDENTDATA_GioiTinh THEN
        v_mismatch := v_mismatch || 'GioiTinh, ';
    END IF;
    IF v_passport_SinhNgay != v_RESIDENTDATA_SinhNgay THEN
        v_mismatch := v_mismatch || 'SinhNgay, ';
    END IF;
    IF v_passport_NoiSinh != v_RESIDENTDATA_NoiSinh THEN
        v_mismatch := v_mismatch || 'NoiSinh, ';
    END IF;
    IF v_passport_NgayCapCCCD != v_RESIDENTDATA_NgayCapCCCD THEN
        v_mismatch := v_mismatch || 'NgayCapCCCD, ';
    END IF;
    IF v_passport_DanToc != v_RESIDENTDATA_DanToc THEN
        v_mismatch := v_mismatch || 'DanToc, ';
    END IF;
    IF v_passport_TonGiao != v_RESIDENTDATA_TonGiao THEN
        v_mismatch := v_mismatch || 'TonGiao, ';
    END IF;
    IF v_passport_SoDienThoai != v_RESIDENTDATA_SoDienThoai THEN
        v_mismatch := v_mismatch || 'SoDienThoai, ';
    END IF;
    IF v_passport_DiaChiThuongTru != v_RESIDENTDATA_DiaChiThuongTru THEN
        v_mismatch := v_mismatch || 'DiaChiDangKyThuongTru, ';
    END IF;
    IF v_passport_DiaChiTamTru != v_RESIDENTDATA_DiaChiTamTru THEN
        v_mismatch := v_mismatch || 'DiaChiDangKyTamTru, ';
    END IF;
    IF v_passport_NgheNghiep != v_RESIDENTDATA_NgheNghiep THEN
        v_mismatch := v_mismatch || 'NgheNghiep, ';
    END IF;
    IF v_passport_CoQuan != v_RESIDENTDATA_CoQuan THEN
        v_mismatch := v_mismatch || 'CoQuan, ';
    END IF;
    IF v_passport_HoTenCha != v_RESIDENTDATA_HoTenCha THEN
        v_mismatch := v_mismatch || 'HoTenCha, ';
    END IF;
    IF v_passport_NgaySinhCha != v_RESIDENTDATA_NgaySinhCha THEN
        v_mismatch := v_mismatch || 'NgaySinhCha, ';
    END IF;
    IF v_passport_HoTenMe != v_RESIDENTDATA_HoTenMe THEN
        v_mismatch := v_mismatch || 'HoTenMe, ';
    END IF;
    IF v_passport_NgaySinhMe != v_RESIDENTDATA_NgaySinhMe THEN
        v_mismatch := v_mismatch || 'NgaySinhMe, ';
    END IF;
    IF v_passport_HoTenVoChong != v_RESIDENTDATA_HoTenVoChong THEN
        v_mismatch := v_mismatch || 'HoTenVoChong, ';
    END IF;
    IF v_passport_NgaySinhVoChong != v_RESIDENTDATA_NgaySinhVoChong THEN
        v_mismatch := v_mismatch || 'NgaySinhVoChong, ';
    END IF;

    -- Kiểm tra và trả về kết quả
    IF v_mismatch IS NULL THEN
        RETURN 'TRUE';
    ELSE
        RETURN 'FALSE';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'FALSE';
    WHEN OTHERS THEN
        RETURN 'FALSE';
END;
/

DECLARE
    -- Khai báo biến để lưu kết quả trả về từ hàm
    v_result VARCHAR2(1000);
BEGIN
    -- Gọi hàm CheckInfo và lưu kết quả vào biến v_result
    v_result := CheckInfo('1234567890340');
    
    -- In kết quả ra
    DBMS_OUTPUT.PUT_LINE('Kết quả kiểm tra: ' || v_result);
END;

CREATE OR REPLACE FUNCTION PassportDataAccessPolicy(
    p_schema_name VARCHAR2,
    p_object_name VARCHAR2
) RETURN VARCHAR2 AS
    v_usertype VARCHAR2(15);
    v_predicate VARCHAR2(4000);
BEGIN
    -- Lấy UserType của người dùng hiện tại
    BEGIN
        SELECT UserType
        INTO v_usertype
        FROM sec_manager.UserAccount
        WHERE CCCD = USER;  -- Sử dụng USER thay vì p_cccd
        DBMS_OUTPUT.PUT_LINE('UserType: ' || v_usertype);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '1=0'; -- Không có quyền truy cập
        WHEN OTHERS THEN
            RETURN '1=0'; -- Lỗi khác, không cho phép truy cập
    END;

    -- Xét quyền dựa trên UserType
    CASE v_usertype
        WHEN 'XT' THEN
            -- Chỉ xem các bản ghi có TRANGTHAI = '1' trong bảng PASSPORTDATA
            v_predicate := 'TRANGTHAI = ''1''';
        WHEN 'XD' THEN
            -- Chỉ xem các bản ghi có TRANGTHAI = '2' trong bảng PASSPORTDATA
            v_predicate := 'TRANGTHAI = ''2''';
        WHEN 'LT' THEN
            -- UserType 'LT' chỉ có quyền xem trường CCCD và TRANGTHAI
            v_predicate := 'TRANGTHAI IS NOT NULL';
        ELSE
            v_predicate := '1=0'; -- Không có quyền với UserType khác
    END CASE;

    -- Trả về predicate để kiểm tra quyền truy cập
    RETURN v_predicate;
END;

CREATE OR REPLACE FUNCTION ResidentDataPolicy(
    p_schema_name VARCHAR2,
    p_object_name VARCHAR2
) RETURN VARCHAR2 AS
    v_usertype VARCHAR2(15);
    v_predicate VARCHAR2(4000);
BEGIN
    -- Lấy UserType của người dùng hiện tại
    BEGIN
        SELECT UserType
        INTO v_usertype
        FROM sec_manager.UserAccount
        WHERE CCCD = USER;  -- Sử dụng USER thay vì p_cccd
        
        DBMS_OUTPUT.PUT_LINE('UserType: ' || v_usertype); -- In ra UserType để kiểm tra
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No data found for CCCD = ' || USER);
            RETURN '1=0'; -- Không có quyền truy cập
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
            RETURN '1=0'; -- Lỗi khác, không cho phép truy cập
    END;
     DBMS_OUTPUT.PUT_LINE('object: ' || p_object_name); -- In ra UserType để kiểm tra
    -- Xét quyền dựa trên UserType
    CASE v_usertype
        WHEN 'XT' THEN
            v_predicate := '1=1'; -- Quyền cho UserType XT
        WHEN 'XD' THEN
            v_predicate := '1=0'; -- Không có quyền với UserType XD
        ELSE
            v_predicate := '1=0'; -- Không có quyền với UserType khác
    END CASE;

    -- Trả về predicate để kiểm tra quyền truy cập
    RETURN v_predicate;
END;


BEGIN
    DBMS_OUTPUT.PUT_LINE('Predicate: ' || PASSPORTDATAAccessPolicy('123456789055', 'PASSPORTDATA'));
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Predicate: ' || PassportRESIDENTDATAAccessPolicy('123456789055', 'RESIDENTDATA'));
END;


BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_manager',
        object_name     => 'PASSPORTDATA',
        policy_name     => 'PassportData_Access_Policy',
        function_schema => 'sec_manager',
        policy_function => 'PassportDataAccessPolicy',
        statement_types => 'SELECT, UPDATE',
        update_check    => FALSE
    );
END;


BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_manager',
        object_name     => 'PassportData',
        policy_name     => 'PassportData_Access_Policy'
    );
END;


BEGIN
    DBMS_RLS.DROP_POLICY(
        object_schema   => 'sec_manager',
        object_name     => 'Resident',
        policy_name     => 'PassportResident_Access_Policy'
    );
END;


BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_manager',
        object_name     => 'RESIDENTDATA',
        policy_name     => 'ResidentData_Policy',
        function_schema => 'sec_manager',
        policy_function => 'ResidentDataPolicy',
        statement_types => 'SELECT',
        update_check    => FALSE
    );
END;

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'sec_manager',
        object_name     => 'PASSPORTDATA',
        policy_name     => 'PassportData_Limit_Policy',
        function_schema => 'sec_manager',
        policy_function => 'PassportDataAccessPolicy',
        statement_types => 'SELECT'
    );
END;
/



CREATE OR REPLACE VIEW sec_manager.PassportData_Limited AS
SELECT SoCCCD, TRANGTHAI
FROM sec_manager.PASSPORTDATA;


CREATE TABLE AUDIT_LOG (
    LOG_ID         NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    USER_TYPE      VARCHAR2(10), -- Loại người dùng (XT, XD, ...)
    ACTION         VARCHAR2(50), -- Hành động (SELECT, UPDATE, ...)
    OBJECT_NAME    VARCHAR2(50), -- Bảng hoặc view được thao tác
    ACTION_TIME    TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Thời gian thực hiện
);



CREATE OR REPLACE TRIGGER TR_AUDIT_LOG
AFTER INSERT OR UPDATE OR DELETE ON sec_manager.PASSPORTDATA
FOR EACH ROW
DECLARE
    v_usertype VARCHAR2(10);
BEGIN
    -- Lấy UserType từ bảng UserAccount
    SELECT UserType
    INTO v_usertype
    FROM sec_manager.useraccount
    WHERE CCCD = USER;

    -- Chỉ ghi log cho XT và XD
    IF v_usertype IN ('XT', 'XD') THEN
        INSERT INTO AUDIT_LOG (USER_TYPE, ACTION, OBJECT_NAME)
        VALUES (v_usertype, SYS_CONTEXT('USERENV', 'ACTION'), 'PASSPORTDATA');
    END IF;
END;
/

CREATE OR REPLACE FUNCTION PolicyFunction_AuditLog(
    schema_name VARCHAR2,
    p_object_name VARCHAR2
) RETURN VARCHAR2 AS
    v_usertype VARCHAR2(10);
    v_predicate VARCHAR2(4000);
BEGIN
    -- Lấy UserType từ bảng UserAccount
    SELECT UserType
    INTO v_usertype
    FROM sec_manager.useraccount
    WHERE CCCD = USER;

    -- Chỉ cho phép GS xem log của XT và XD
    IF v_usertype = 'GS' AND p_object_name = 'AUDIT_LOG' THEN
        v_predicate := 'USER_TYPE IN (''XT'', ''XD'')';
    ELSE
        v_predicate := '1=0'; -- Không cho phép truy cập
    END IF;

    RETURN v_predicate;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema    => 'sec_manager',
        object_name      => 'AUDIT_LOG',
        policy_name      => 'AuditLog_Policy',
        function_schema  => 'sec_manager',
        policy_function  => 'PolicyFunction_AuditLog',
        statement_types  => 'SELECT',
        enable           => TRUE
    );
END;
/


grant select on sec_manager.AUDIT_LOG to "123456789053";

SELECT * FROM DBA_AUDIT_TRAIL;

GRANT SELECT ANY DICTIONARY TO "123456789053";

GRANT AUDIT_VIEWER TO "123456789053";

AUDIT INSERT, UPDATE, DELETE ON sec_manager.PASSPORTDATA BY ACCESS;

SELECT 
    username, 
    action_name, 
    obj_name, 
    timestamp, 
    sql_text 
FROM 
    dba_audit_trail
WHERE 
    obj_name = 'PASSPORTDATA' AND
    owner = 'sec_manager'
ORDER BY 
    timestamp DESC;


