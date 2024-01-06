from flask import Flask, request, jsonify
from redis import Redis, StrictRedis
from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement, ConsistencyLevel
import logging as log
import time, subprocess

log.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p',filename='urlshortener.log', level=log.INFO)

redis_client = StrictRedis(host='redis-master', port=6379, decode_responses=True)
 
redis_host = "redis-master"
redis_slave = "redis-slave"
redis_port = 6379
channel = 'cassandra_channel'

# function to publish data to redis channel
def publish_data(data):
    redis_client.publish(channel, data)
    
# function to subscribe to redis channel
def subscribe_data():
    pubsub = redis_client.pubsub()
    pubsub.subscribe(channel)

app = Flask(__name__)

# curl -X GET "http://localhost:5000/aaa"
@app.route('/<short_url>', methods=['GET'])
def get_long_url(short_url):
    try: 
        # Connect to the selected Redis slave
        redis_slave_client = StrictRedis(host=redis_slave, port=6380)

        cached_result = redis_slave_client.get(short_url)
        if cached_result:
            log.info(f"Cache hit for short URL: {short_url}")
            return jsonify(cached_result.decode('utf-8')), 307

        # If not found in the cache, query Cassandra and update the cache
        try:
            query = "SELECT long_url FROM your_table WHERE short_url = ?"
            prepared_query = cassandra_session.prepare(query)

            statement = prepared_query.bind([short_url])
            result = cassandra_session.execute(statement)
        except Exception as error:
            log.error("Error processing GET request to Cassandra: {}".format(error))
            return jsonify({'error': 'Internal server error'}), 500
        if not result:
            log.error("404: Short URL not found")
            return jsonify({'error': 'Short URL not found'}), 404

        long_url = result[0].long_url

        # Cache the result in Redis 
        redis_client.set(short_url, long_url)

        return jsonify(long_url), 307
    except Exception as e:
        log.error(f"Error processing GET request: {e}")
        return jsonify({'error': 'Internal server error'}), 500

# curl -X PUT "http://localhost:5000/?short=aaa&long=11111"
@app.route('/', methods=['PUT'])
def create_short_url():
    try:
        short_url = request.args.get('short')
        long_url = request.args.get('long')

        if not short_url or not long_url:
            log.error("400: Bad request")
            return jsonify({'error': 'Both short and long URL must be provided'}), 400

        # Cache the result in Redis
        redis_client.set(short_url, long_url)
        # Publish the result to Redis channel
        publish_data(short_url + " " + long_url)

        return jsonify({'message': 'Short URL created successfully'}), 201
    except Exception as e:
        log.error(f"Error processing PUT request: {e}")
        return jsonify({'error': f'Internal server error {e}'}), 500


if __name__ == '__main__':
    # Connect to Cassandra
    log.info("Connecting to Cassandra")
    cassandra_nodes = ['10.128.1.37', '10.128.2.37', '10.128.3.37', '10.128.4.37']
    cassandra_cluster = Cluster(cassandra_nodes)
    cassandra_session = cassandra_cluster.connect()

    # Create keyspace if it doesn't exist
    log.info("Initializing keyspace")
    keyspace_name = 'your_keyspace'
    cassandra_session.execute(f"CREATE KEYSPACE IF NOT EXISTS {keyspace_name} WITH replication = {{'class': 'SimpleStrategy', 'replication_factor': 3}}")

    # Use the keyspace
    cassandra_session.set_keyspace(keyspace_name)

    # Create table if it doesn't exist
    table_name = 'your_table'
    cassandra_session.execute(f"CREATE TABLE IF NOT EXISTS {table_name} (short_url TEXT PRIMARY KEY, long_url TEXT)")

    # Create a redis client
    log.info("Initilizing redis")
    redis_client = StrictRedis(host=redis_host, port=redis_port, db=0)

    subscribe_data()
    
    log.info("Launching app")
    app.run(debug=True, host='0.0.0.0', port=5000)
