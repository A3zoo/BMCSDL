from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, Date, String, CheckConstraint, ForeignKey, CHAR, Integer
import uuid
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from datetime import date
from database import get_user_session

class ResidentData(Base):
    __tablename__ = 'RESIDENTDATA'
    __table_args__ = (
        {'extend_existing': True, 'quote': False, 'schema': 'SEC_MGR'}
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
    Id: Optional[uuid.UUID]
    HoVaTen: Optional[str] 
    GioiTinh: Optional[int] 
    SinhNgay: Optional[date] 
    NoiSinh: Optional[str] 
    SoCCCD: Optional[str] 
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


def get_passport_data(cccd):
    Session = get_user_session()
    with Session() as session_db:
        passport = session_db.query(ResidentData).filter_by(SoCCCD=cccd).first()
        if passport:
            return ResidentDataModel.model_validate(passport)
        else:
            return None 