# coding: UTF-8
# input script according to definition of "run" interface
import random
import numpy as np
import uuid
import pyspark

from trailer import logger
from pyspark import SparkContext
from pyspark.sql import SQLContext
from graph_lib import pageRank, weightedShortestPaths, shortestPaths, connectedComponents, stronglyConnectedComponents, triangleCount, labelPropagation


def gen_evt_id(prefix):
    return prefix + '_' + str(uuid.uuid4())


def create_bankdata(sc, sqlContext):
    jobs = ['technician', 'management', 'blue-collar', 'entrepreneur', 'services', 'admin', 'housemaid', 'unemployed', 'unknown', 'retired']
    maritals = ['married', 'divorced', 'single']
    educations = ['unknown', 'university.degree', 'professional.course', 'high.school', 'basic.4y', 'basic.6y', 'basic.9y']
    flag = ['yes', 'no']
    contacts = ['cellular', 'telephone']
    months = ['jun', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
    days_of_week = ['mon', 'tue', 'wed', 'thu', 'fri']
    poutcomes = ['nonexistent', 'success', 'failure']
    labels = [0, 1]
    dates = ['2015-3-20', '2015-4-20', '2015-4-21']

    def _extend_bank_record(record_id):
        fields = [record_id]
        fields.append(random.randint(18, 85))  # age
        fields.append(random.choice(jobs))  # job
        fields.append(random.choice(maritals))  # marital
        fields.append(random.choice(educations))  # education
        fields.append(random.choice(flag))  # default
        fields.append(random.choice(flag))  # housing
        fields.append(random.choice(flag))  # load
        fields.append(random.choice(contacts))  # contact
        fields.append(random.choice(months))  # month
        fields.append(random.choice(days_of_week))  # day_of_week
        fields.append(random.randint(1, 199))  # duration
        fields.append(random.randint(1, 199))  # campaign
        fields.append(random.choice([3, 6, 999]))  # pdays
        fields.append(random.choice([0, 1]))  # previous
        fields.append(random.choice(poutcomes))  # poutcome
        fields.append(float('%.2f' % np.random.uniform(-3., 2.)))  # emp_var_rate
        fields.append(float('%.3f' % np.random.uniform(92., 94.)))  # cons_price_idx
        fields.append(random.choice(labels))  # y
        fields.append(random.choice(dates))  # date1
        fields.append('2015-4-20')  # date2
        fields.append('2015-4-20')  # date3
        return fields

    print('generate bank_data start')
    num_bankdata = 100 * 10000 * 10000
    bankdata_rdd = sc.parallelize(xrange(num_bankdata), 4000) \
        .map(lambda x: gen_evt_id('acc')) \
        .map(lambda id: _extend_bank_record(id)) \
        .repartition(800)

    schema = ['id', 'age', 'job', 'marital', 'education', 'default', 'housing', 'loan', 'contact', 'month', 'day_of_week', 'duration', 'campaign', 'pdays', 'previous', 'poutcome', 'emp_var_rate', 'cons_price_idx', 'y', 'date1', 'date2', 'date3']
    bankdata_df = sqlContext.createDataFrame(bankdata_rdd, schema)

    write_dir = 'hdfs:///user/srv_kp_vendor/zjtest/pre_data0501_100y'
    bankdata_df.write.parquet(write_dir)
    print('write band_data success')


def do_something(sc, sqlContext):
    # define process to be executed
    print "Hello World"
    create_bankdata(sc, sqlContext)


def run(t1, context_string):
    """
    Define main line of script (two input for instance). Given input data (Dataframes) and configuration output data will be returned (list of Dataframes)
    Params:
    t1    Dataframe, upstream data, whose name should be consistent with first slot definition
    context_strinig    String, task config whose name should be "context_string"
    Return:
    Wrap one or more output data as list of dataframes
    """
    sc = SparkContext._active_spark_context
    sqlContext = SQLContext(sc)
    do_something(sc, sqlContext)  # data processing

    # Input Source handler for Prophet Platform
    return [t1]
