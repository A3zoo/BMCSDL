from functools import wraps

from flask import jsonify, session

from database import get_session


def auth_middleware(f):
    """This decorator will filter out unauthorized connections."""

    @wraps(f)
    def __auth_middleware(*args, **kwargs):# -> tuple[Response, Literal[403]] | Any:# -> tuple[Response, Literal[403]] | Any:
        try:
            get_session(session['user'], session['password'])
            return f(*args, **kwargs)
        except Exception as e:
            return jsonify({
                "message": "Unauthorized access. User not logged in. " +  str(e),
                "status": 403
            }), 403
            

    return __auth_middleware
