from flask import Flask, render_template, redirect, url_for, flash, request
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from models.UserAccount import UserAccount
from database import get_session
from sqlalchemy import text

def login_duy(session, sdt, password):
    result = session.execute(
            text('SELECT CHECK_PASSWORD(:sdt,:password) AS result  FROM dual'),
            {"sdt": sdt, "password": password}
        ).fetchall()
    return result[0]
