
import web

if __name__ == '__main__':
    print('Hello Docker world!')
    web.app.run(debug=True, host='0.0.0.0', port=8080)
