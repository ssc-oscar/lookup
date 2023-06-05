from datetime import datetime, timedelta, tzinfo
import clickhouse_driver as clickhouse
import oscar

class Clickhouse_DB(object):
    """ Clickhouse_DB class represents an instance of the clickhouse client
        It is initialized with a table name and a host name for the database
    """
    def __init__(self, tb_name, db_host):
        self.tb_name = tb_name
        self.db_host = db_host
        self.client_settings = {'strings_as_bytes':True, 'max_block_size':100000}
        self.client = clickhouse.Client(host=self.db_host, settings=self.client_settings)

    def query(self, query_str):
        return self.client.execute(query_str)
    
    def query_iter(self, query_str):
        for row in self.client.execute_iter(query_str):
            yield row

    def query_select(self, s_col, s_from, s_start, s_end):
        # normal query
        s_where = self.__where_condition(s_start, s_end)
        query_str = 'select {} from {} where {}'.format(s_col, s_from, s_where)
        return self.client.execute(query_str)
        
    def query_select_iter(self, s_col, s_from, s_start, s_end):
        # iterative query
        s_where = self.__where_condition(s_start, s_end)
        query_str = 'select {} from {} where {}'.format(s_col, s_from, s_where)
        for row in self.client.execute_iter(query_str):
            yield row
    
    def __where_condition(self, start, end):
        # checks if start and end date or time is valid and build the where
        # clause
        dt = 'time'
        if not self.__check_time(start, end):
            dt = 'date'
            start = 'toDate(\'{}\')'.format(start)
            end = 'toDate(\'{}\')'.format(end) if end else None
            
        if end is None:
            return '{}={}'.format(dt, start)
        return '{}>={}  AND {}<={}'.format(dt, start, dt, end)

    def __check_time(self, start, end):
        # make sure start and end are of the same type and must be either
        # strings or ints
        if start is None:
            raise ValueError('start time cannot be None')
        if not isinstance(start, (int,str)):
            raise ValueError('start time must be either int or string')
        if end is not None and not isinstance(end, (int, str)):
            raise ValueError('end time must be either int or string')
        if end is not None and type(start) is not type(end):
            raise ValueError('start and end must be of the same type')
        return isinstance(start, int)


class Time_commit_info(Clickhouse_DB):
    """ Time_commit_info class is initialized with table name and database host
    name the default table for commits is commits_all, and the default host is
    localhost No connection is established before the query is made.
      CREATE TABLE commit_$v (sha1 FixedString(20), time Int32, tc Int32, tree FixedString(20), parent String, taz String, tcz String, author String, commiter String, project String, comment String) ENGINE = MergeTree() ORDER BY time" |clickhouse-client --host=$h
    The 'commits_all' table description is the following:
        |__name___|______type_______|
        | sha1    | FixedString(20) |
        | time    | Int32           |
        | timeCmt | Int32           |
        | tree    | FixedString(20) |
        | parent  | String          |
        | TZAuth  | String          |
        | TZCmt   | String          |
        | author  | String          |
        | commiter| String          |
        | project | String          |
        | comment | String          |
    """
    columns = ['sha1', 'time', 'timeCmt', 'tree', 'parent', 'taz', 'tcz', 'author', 'commiter', 'project', 'comment' ]
    def __init__(self, tb_name='commits_all', db_host='localhost'):
        super(Time_commit_info, self).__init__(tb_name, db_host)
    
    def commit_counts(self, start, end=None):
        """ return the count of commits between given date and time
        >>> t = Time_commit_info()
        >>> t.commit_counts(1568656268)
        8
        """
        return self.query_select('count(*)', self.tb_name, start, end)[0][0]
    
    def commits(self, start, end=None):
        """ return a generator of Commit instances within a given date and time
        >>> t = Time_commit_info()
        >>> commits = t.commits_iter(1568656268)
        >>> c = commits.next()
        >>> type(c)
        <class 'oscar.Commit'>
        >>> c.parent_shas
        ('9c4cc4f6f8040ed98388c7dedeb683469f7210f5',)
        """
        for sha in self.commits_shas(start, end):
            print (sha)
            yield oscar.Commit(sha)

    def commits_shas(self, start, end=None):
        """ return a generator of all sha1 within the given time and date
        >>> t = Time_commit_info()
        >>> for sha1 in t.commits_shas(1568656268):
        ...     print(sha1)
        """
        for row in self.query_select_iter(
                'lower(hex(sha1))', self.tb_name, start, end):
            yield row[0]


