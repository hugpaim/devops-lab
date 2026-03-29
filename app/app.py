import time
import os
from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from flask import Response

app = Flask(__name__)

# Prometheus metrics

REQUEST_COUNT = Counter(
    'app_request_count_total',
    'Total request count',
    ['method', 'endpoint', 'status']
)
REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds',
    'Request latency in seconds',
    ['endpoint']
)

APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
START_TIME = time.time()


@app.before_request
def before_request():
    pass


@app.after_request
def after_request(response):
    return response


@app.route('/')
def index():
    start = time.time()
    REQUEST_COUNT.labels(method='GET', endpoint='/', status=200).inc()
    REQUEST_LATENCY.labels(endpoint='/').observe(time.time() - start)
    return jsonify({
        'service': 'devops-lab',
        'version': APP_VERSION,
        'status': 'running',
        'uptime_seconds': round(time.time() - START_TIME, 2)
    })


@app.route('/health')
def health():
    REQUEST_COUNT.labels(method='GET', endpoint='/health', status=200).inc()
    return jsonify({
        'status': 'healthy',
        'version': APP_VERSION,
        'uptime_seconds': round(time.time() - START_TIME, 2)
    }), 200


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint."""
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


@app.route('/ready')
def ready():
    """Kubernetes readiness probe endpoint."""
    return jsonify({'status': 'ready'}), 200


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)
