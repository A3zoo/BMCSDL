from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, Date, String, Integer,Boolean, CheckConstraint, ForeignKey, CHAR, Nu
import uuid
from pydantic import BaseModel, Field, UUID4, ConfigDict
from typing import Optional
from datetime import date
from database import user_Session as Session


class PassportData(Base):
    __tablename__ = 'PASSPORTREGISTION'
    __table_args__ = (
        CheckConstraint("CoGanChip IN ('Y', 'N')", name='ck_CoGanChip'),
        {'extend_existing': True, 'quote': False}
    )

    Id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, name='ID'
    )
    HoVaTen: Mapped[str] = mapped_column(String(100), nullable=False, name='HOVATEN')
    GioiTinh: Mapped[int] = mapped_column(Integer, nullable=True, name='GIOITINH')
    SinhNgay: Mapped[Date] = mapped_column(Date, nullable=True, name='SINHNGAY')
    NoiSinh: Mapped[str] = mapped_column(String(100), nullable=True, name='NOISINH')
    SoCCCD: Mapped[str] = mapped_column(String(20), ForeignKey('UserAccount(CCCD)', ondelete='CASCADE'), nullable=True, name='SOCCCD')
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
    Id: UUID4 = Field(alias="ID")
    HoVaTen: str = Field(..., max_length=100, alias="HOVATEN")
    GioiTinh: Optional[int] = Field(None, alias="GIOITINH")
    SinhNgay: Optional[date] = Field(None, alias="SINHNGAY")
    NoiSinh: Optional[str] = Field(None, max_length=100, alias="NOISINH")
    SoCCCD: Optional[str] = Field(None, max_length=20, alias="SOCCCD")
    NgayCapCCCD: Optional[date] = Field(None, alias="NGAYCAPCCCD")
    DanToc: Optional[str] = Field(None, max_length=50, alias="DANTOC")
    TonGiao: Optional[str] = Field(None, max_length=50, alias="TONGIAO")
    SoDienThoai: Optional[str] = Field(None, max_length=15, alias="SODIENTHOAI")
    DiaChiDangKyThuongTru: Optional[str] = Field(None, max_length=200, alias="DIACHIDANGKYTHUONGTRU")
    DiaChiDangKyTamTru: Optional[str] = Field(None, max_length=200, alias="DIACHIDANGKYTAMTRU")
    NgheNghiep: Optional[str] = Field(None, max_length=100, alias="NGHENGHIEP")
    CoQuan: Optional[str] = Field(None, max_length=100, alias="COQUAN")
    HoTenCha: Optional[str] = Field(None, max_length=100, alias="HOTENCHA")
    NgaySinhCha: Optional[date] = Field(None, alias="NGAYSINHCHA")
    HoTenMe: Optional[str] = Field(None, max_length=100, alias="HOTENME")
    NgaySinhMe: Optional[date] = Field(None, alias="NGAYSINHME")
    HoTenVoChong: Optional[str] = Field(None, max_length=100, alias="HOTENVOCHONG")
    NgaySinhVoChong: Optional[date] = Field(None, alias="NGAYSINHVOCHONG")
    NoiDungDeNghi: Optional[str] = Field(None, max_length=500, alias="NOIDUNGDENGHI")
    CoGanChip: Optional[int] = Field(None, alias="COGANCHIP")
    NoiTiepNhan: Optional[str] = Field(None, max_length=100, alias="NOITIEPNHAN")
    DiaChiNopHoSo: Optional[str] = Field(None, max_length=200, alias="DIACHINOPHOSO")
    TrangThai: Optional[int] = Field(None, alias="TRANGTHAI")

def create_passport_data(payload: PassportDataModel):
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
    with Session() as session:
        passport = session.query(PassportData).filter_by(SoCCCD=cccd).first()
        if passport:
            return PassportDataModel.model_validate(passport)
        else:
            return None 


def update_status_passport_data_by_cccd(cccd, status):
    with Session() as session:
        passport = session.query(PassportData).filter_by(SoCCCD=cccd).first()
        if passport:
            passport.TrangThai = status
            session.commit()
            return PassportDataModel.model_validate(passport) 
        else:
            return None


def get_all_passport_data():
    with Session() as session:
        passport_data_list = session.query(PassportData).all()
        return [PassportDataModel.model_validate(passport) for passport in passport_data_list]
