import os
import boto3
import tweepy
twitter_bearer_token = os.environ["AAAAAAAAAAAAAAAAAAAAANaMigEAAAAAcMk3m5sLSX2lokFSkint4tjfe18%3DurPtJl8ET1FurRzD6Fr6zkVsqiC7CN7YglEaNMPzC0i1wsnpA4"]
hashtag_query = os.environ["#willsmithoscars"]

client = tweepy.Client(
    bearer_token=twitter_bearer_token)
tweets = client.search_recent_tweets(query=hashtag_query)

def lambda_handler(event, context):
    a = []
    try:
        for tweet in tweets.data:
            print(tweet.text)
            a.append(tweet.text)
    except tweepy.errors.TweepyException as e:
        print(e)
    return a
