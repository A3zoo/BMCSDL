from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, Date, String, Integer,Boolean, CheckConstraint, ForeignKey, CHAR, LargeBinary
import uuid
from pydantic import BaseModel, Field, UUID4, ConfigDict
from typing import Optional
from datetime import date
from sqlalchemy.inspection import inspect
from database import get_user_session, get_session

class PassportData(Base):
    __tablename__ = 'PASSPORTDATA'
    Id: Mapped[uuid.UUID] =  mapped_column(
        LargeBinary(16),  # Sử dụng LargeBinary(16) để tương ứng với RAW(16) trong Oracle
        primary_key=True, 
        default=lambda: uuid.uuid4().bytes,  # Lấy bytes từ UUID
        name='ID'
    )
    HoVaTen: Mapped[str] = mapped_column(String(100), nullable=False, name='HOVATEN')
    GioiTinh: Mapped[int] = mapped_column(Integer, nullable=True, name='GIOITINH')
    SinhNgay: Mapped[Date] = mapped_column(Date, nullable=True, name='SINHNGAY')
    NoiSinh: Mapped[str] = mapped_column(String(100), nullable=True, name='NOISINH')
    SoCCCD: Mapped[str] = mapped_column(String(20), name='SOCCCD')
    NgayCapCCCD: Mapped[Date] = mapped_column(Date, nullable=True, name='NGAYCAPCCCD')
    DanToc: Mapped[str] = mapped_column(String(50), nullable=True, name='DANTOC')
    TonGiao: Mapped[str] = mapped_column(String(50), nullable=True, name='TONGIAO')
    SoDienThoai: Mapped[str] = mapped_column(String(15), nullable=True, name='SODIENTHOAI')
    DiaChiDangKyThuongTru: Mapped[str] = mapped_column(String(200), nullable=True, name='DIACHIDANGKYTHUONGTRU')
    DiaChiDangKyTamTru: Mapped[str] = mapped_column(String(200), nullable=True, name='DIACHIDANGKYTAMTRU')
    NgheNghiep: Mapped[str] = mapped_column(String(100), nullable=True, name='NGHENGHIEP')
    CoQuan: Mapped[str] = mapped_column(String(100), nullable=True, name='COQUAN')
    HoTenCha: Mapped[str] = mapped_column(String(100), nullable=True, name='HOTENCHA')
    NgaySinhCha: Mapped[Date] = mapped_column(Date, nullable=True, name='NGAYSINHCHA')
    HoTenMe: Mapped[str] = mapped_column(String(100), nullable=True, name='HOTENME')
    NgaySinhMe: Mapped[Date] = mapped_column(Date, nullable=True, name='NGAYSINHME')
    HoTenVoChong: Mapped[str] = mapped_column(String(100), nullable=True, name='HOTENVOCHONG')
    NgaySinhVoChong: Mapped[Date] = mapped_column(Date, nullable=True, name='NGAYSINHVOCHONG')
    NoiDungDeNghi: Mapped[str] = mapped_column(String(500), nullable=True, name='NOIDUNGDE' 'NGHI')
    CoGanChip: Mapped[int] = mapped_column(Integer, nullable=True, name='COGANCHIP')
    NoiTiepNhan: Mapped[str] = mapped_column(String(100), nullable=True, name='NOITIEPNHAN')
    DiaChiNopHoSo: Mapped[str] = mapped_column(String(200), nullable=True, name='DIACHINOPHOSO')
    TrangThai: Mapped[int] = mapped_column(Integer, nullable=True, name='TRANGTHAI')

class PassportDataModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    Id: Optional[UUID4] 
    HoVaTen: Optional[str]
    GioiTinh: Optional[int] 
    SinhNgay: Optional[date] 
    NoiSinh: Optional[str] 
    SoCCCD: str
    NgayCapCCCD: Optional[date] 
    DanToc: Optional[str] 
    TonGiao: Optional[str] 
    SoDienThoai: Optional[str] 
    DiaChiDangKyThuongTru: Optional[str] 
    DiaChiDangKyTamTru: Optional[str]
    NgheNghiep: Optional[str] 
    CoQuan: Optional[str] 
    HoTenCha: Optional[str] 
    NgaySinhCha: Optional[date] 
    HoTenMe: Optional[str]
    NgaySinhMe: Optional[date] 
    HoTenVoChong: Optional[str] 
    NgaySinhVoChong: Optional[date] 
    NoiDungDeNghi: Optional[str] 
    CoGanChip: Optional[int]
    NoiTiepNhan: Optional[str]
    DiaChiNopHoSo: Optional[str] 
    TrangThai: int

def create_passport_data(payload: PassportDataModel):
    Session = get_user_session()
    with Session() as session:
        passport = PassportData(
            Id=payload.Id,
            HoVaTen=payload.HoVaTen,
            GioiTinh=payload.GioiTinh,
            SinhNgay=payload.SinhNgay,
            NoiSinh=payload.NoiSinh,
            SoCCCD=payload.SoCCCD,
            NgayCapCCCD=payload.NgayCapCCCD,
            DanToc=payload.DanToc,
            TonGiao=payload.TonGiao,
            SoDienThoai=payload.SoDienThoai,
            DiaChiDangKyThuongTru=payload.DiaChiDangKyThuongTru,
            DiaChiDangKyTamTru=payload.DiaChiDangKyTamTru,
            NgheNghiep=payload.NgheNghiep,
            CoQuan=payload.CoQuan,
            HoTenCha=payload.HoTenCha,
            NgaySinhCha=payload.NgaySinhCha,
            HoTenMe=payload.HoTenMe,
            NgaySinhMe=payload.NgaySinhMe,
            HoTenVoChong=payload.HoTenVoChong,
            NgaySinhVoChong=payload.NgaySinhVoChong,
            NoiDungDeNghi=payload.NoiDungDeNghi,
            CoGanChip=payload.CoGanChip,
            NoiTiepNhan=payload.NoiTiepNhan,
            DiaChiNopHoSo=payload.DiaChiNopHoSo,
            TrangThai=payload.TrangThai
        )
        session.add(passport)
        session.commit()
        return passport


def get_passport_data(cccd):
    Session = get_user_session()
    with Session() as session:
        passport = session.query(PassportData).filter_by(SoCCCD=cccd).first()
        if passport:
            return PassportDataModel.model_validate(passport)
        else:
            return None 


def update_status_passport_data_by_cccd(cccd, status):
    Session = get_session('db_manager', 'quangduy')
    with Session() as session_db:
        passport = session_db.query(PassportData).filter_by(SoCCCD=cccd).first()
        if passport:
            passport.TrangThai = status
            session_db.commit()
            return PassportDataModel.model_validate(passport) 
        else:
            return None


def get_all_passport_data():
    Session = get_user_session()
    with Session() as session_db:
        passport_data_list = session_db.query(PassportData).all()
        return [PassportDataModel.model_validate(passport) for passport in passport_data_list]
