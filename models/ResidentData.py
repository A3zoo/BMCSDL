from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, Date, String, CheckConstraint, ForeignKey, CHAR
import uuid

class ResidentData(Base):
    __tablename__ = 'ResidentData'
    __table_args__ = (
        {'extend_existing': True, 'quote': False}
    )

    Id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, name='ID'
    )
    HoVaTen: Mapped[str] = mapped_column(String(100), nullable=False, name='HOVATEN')
    GioiTinh: Mapped[str] = mapped_column(String(10), nullable=True, name='GIOITINH')
    SinhNgay: Mapped[Date] = mapped_column(Date, nullable=True, name='SINHNGAY')
    NoiSinh: Mapped[str] = mapped_column(String(100), nullable=True, name='NOISINH')
    SoCCCD: Mapped[str] = mapped_column(String(20), nullable=True, name='SOCCCD')
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
    UserId: Mapped[int] = mapped_column(ForeignKey('UserAccount.ID', ondelete='CASCADE'), nullable=True, name='USERID')
    TrangThai: Mapped[str] = mapped_column(String(20), nullable=True, name='TRANGTHAI')