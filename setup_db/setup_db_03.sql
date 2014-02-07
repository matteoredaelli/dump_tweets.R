alter table search_results
  ADD  FOREIGN KEY search_results_tweets_fk (tweet_id)
    REFERENCES tweets (id)
    ON DELETE cascade
    ON UPDATE cascade;

alter table search_results
  ADD  FOREIGN KEY search_results_search_for_fk (id)
    REFERENCES search_for (id)
    ON DELETE cascade
    ON UPDATE cascade;
