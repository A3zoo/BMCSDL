from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, Date, String, CheckConstraint, ForeignKey, CHAR, Integer
import uuid
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from datetime import date
from database import user_Session as Session


class ResidentData(Base):
    __tablename__ = 'RESIDENT'
    __table_args__ = (
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
  

class ResidentDataModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    Id: UUID = Field(..., alias="ID")
    HoVaTen: str = Field(..., max_length=100)
    GioiTinh: Optional[int] = Field(None, ge=0, le=1)  # Giới tính có thể là 0 hoặc 1
    SinhNgay: Optional[date] = None
    NoiSinh: Optional[str] = Field(None, max_length=100)
    SoCCCD: Optional[str] = Field(None, max_length=20)
    NgayCapCCCD: Optional[date] = None
    DanToc: Optional[str] = Field(None, max_length=50)
    TonGiao: Optional[str] = Field(None, max_length=50)
    SoDienThoai: Optional[str] = Field(None, max_length=15)
    DiaChiDangKyThuongTru: Optional[str] = Field(None, max_length=200)
    DiaChiDangKyTamTru: Optional[str] = Field(None, max_length=200)
    NgheNghiep: Optional[str] = Field(None, max_length=100)
    CoQuan: Optional[str] = Field(None, max_length=100)
    HoTenCha: Optional[str] = Field(None, max_length=100)
    NgaySinhCha: Optional[date] = None
    HoTenMe: Optional[str] = Field(None, max_length=100)
    NgaySinhMe: Optional[date] = None
    HoTenVoChong: Optional[str] = Field(None, max_length=100)
    NgaySinhVoChong: Optional[date] = None


def get_passport_data(cccd):
    with Session() as session:
        passport = session.query(ResidentData).filter_by(SoCCCD=cccd).first()
        if passport:
            return ResidentDataModel.model_validate(passport)
        else:
            return None 