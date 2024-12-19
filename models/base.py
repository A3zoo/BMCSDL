from sqlalchemy.orm import DeclarativeBase
from env import env_data


class Base(DeclarativeBase):
    __table_args__ = (
       {'extend_existing': True, 'quote': False, 'schema': env_data.base_schema}
    )

