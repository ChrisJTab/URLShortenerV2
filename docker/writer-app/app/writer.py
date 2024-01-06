import redis
from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement, ConsistencyLevel
import logging as log

log.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p',filename='writer.log', level=log.INFO)

redis_host = 'redis-master'
redis_port = 6379
channel = 'cassandra_channel'


def write_data_to_cassandra(data):
    # Your code to write data to Cassandra
    # data is partitioned into short_url + " " + long_url
    try:
        data = data.decode('utf-8')
        data = data.split(" ")
        short_url = data[0]
        long_url = data[1]

        query = "INSERT INTO your_keyspace.your_table (short_url, long_url) VALUES (?, ?)"
        prepared_statement = cassandra_session.prepare(query)
        bound_statement = prepared_statement.bind((short_url, long_url))
        try:
            cassandra_session.execute(bound_statement, (short_url, long_url))
        except Exception as error:
            log.error(f"Error processing query: {e}")
    except Exception as e:
        log.error(f"Error processing Message: {e}")
    

if __name__ == '__main__':
    # Connect to Redis
    redis_client = redis.StrictRedis(host=redis_host, port=redis_port)

    # Connect to Cassandra
    cassandra_nodes = ['10.128.1.37', '10.128.2.37', '10.128.3.37', '10.128.4.37']
    cassandra_cluster = Cluster(cassandra_nodes)
    cassandra_session = cassandra_cluster.connect()

    # Create keyspace if it doesn't exist
    keyspace_name = 'your_keyspace'
    cassandra_session.execute(f"CREATE KEYSPACE IF NOT EXISTS {keyspace_name} WITH replication = {{'class': 'SimpleStrategy', 'replication_factor': 3}}")

    # Use the keyspace
    cassandra_session.set_keyspace(keyspace_name)

    # Create table if it doesn't exist
    table_name = 'your_table'
    cassandra_session.execute(f"CREATE TABLE IF NOT EXISTS {table_name} (short_url TEXT PRIMARY KEY, long_url TEXT)")

    # Subscribe to the Redis channel
    redis_pubsub = redis_client.pubsub()
    redis_pubsub.subscribe(channel)

    # Listen for messages from Redis and write to Cassandra
    for message in redis_pubsub.listen():
        if message['type'] == 'message':
            data = message['data']
            # Your code to process and write data to Cassandra
            write_data_to_cassandra(data)
    

