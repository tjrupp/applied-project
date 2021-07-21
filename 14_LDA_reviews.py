#Script for performing topic modelling on patchnotes
#Author: Tim Jonathan Rupp
#DISC applied project

#import needed modules
import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords

import re

import pandas as pd

from pprint import pprint

import spacy

import gensim
import gensim.corpora as corpora
from gensim.utils import simple_preprocess
from gensim.models import CoherenceModel

import pyLDAvis.gensim_models

import matplotlib.pyplot as plt

import sqlite3 as sql

#define stop words
stop_words = stopwords.words('english')

#connect to SQLite database
conn = sql.connect('app_reviews.sqlite')

#read reviews from database
reviews = pd.read_sql('SELECT content FROM reviews;', conn)

#convert to list
reviews = reviews.values.tolist()

#convert contents to string
reviews = [str(i) for i in reviews]

#save as all texts
all_texts = reviews

#define function for removing emojis
def remove_emojis(data):
    emoj = re.compile("["
                      u"\U0001F600-\U0001F64F"
                      u"\U0001F300-\U0001F5FF"  
                      u"\U0001F680-\U0001F6FF"  
                      u"\U0001F1E0-\U0001F1FF"  
                      u"\U00002500-\U00002BEF"  
                      u"\U00002702-\U000027B0"
                      u"\U00002702-\U000027B0"
                      u"\U000024C2-\U0001F251"
                      u"\U0001f926-\U0001f937"
                      u"\U00010000-\U0010ffff"
                      u"\u2640-\u2642"
                      u"\u2600-\u2B55"
                      u"\u200d"
                      u"\u23cf"
                      u"\u23e9"
                      u"\u231a"
                      u"\ufe0f"  
                      u"\u3030"
                      "]+", re.UNICODE)
    return re.sub(emoj, '', data)

#remove emojis and save patch notes in text_list
text_list = []
for text in all_texts:
    text_list.append(remove_emojis(text))

#remove line breaks
text_list = [re.sub('\\s+', ' ', sent) for sent in text_list]

#define function for tokenisation, normalisation and removal of punctuation
def sent_to_words(sentences):
    for sentence in sentences:
        yield gensim.utils.simple_preprocess(str(sentence), deacc=True)

#use on text_list
data_words = list(sent_to_words(text_list))

print(data_words[:4])

#define bigrams (have to occur min 5 times)
bigram = gensim.models.Phrases(data_words, min_count=5, threshold=100)
bigram_mod = gensim.models.phrases.Phraser(bigram)

#define function to remove stopwords
def remove_stopwords(texts):
    return [[word for word in simple_preprocess(str(doc)) if word not in stop_words] for doc in texts]

#function to get bigrams
def make_bigrams(texts):
    return [bigram_mod[doc] for doc in texts]

#function for lemmatisation and POS-tagging
#keep only nouns, adjectives, verbs and adverbs
def lemmatization(texts, allowed_postags=['NOUN', 'ADJ', 'VERB', 'ADV']):
    texts_out = []
    for sent in texts:
        doc = nlp(" ".join(sent))
        texts_out.append([token.lemma_ for token in doc if token.pos_ in allowed_postags])
    return texts_out

#remove stopwords
data_words_nostops = remove_stopwords(data_words)

#calculate bigrams
data_words_bigrams = make_bigrams(data_words_nostops)

#define lemmatiser and POS-tagger
nlp = spacy.load('en_core_web_sm', disable=['parser', 'ner'])

#lemmatise and tag words
data_lemmatized = lemmatization(data_words_bigrams, allowed_postags=['NOUN', 'ADJ', 'VERB', 'ADV'])

print(data_lemmatized[:1])

#create dictionary
id2word = corpora.Dictionary(data_lemmatized)

#create corpus
texts = data_lemmatized

#TF-IDF (term frequency and inverse document frequency
corpus = [id2word.doc2bow(text) for text in texts]

print(corpus[:1])

#build model
lda_model = gensim.models.ldamodel.LdaModel(corpus=corpus,
                                            id2word=id2word,
                                            num_topics=20,
                                            random_state=100,
                                            update_every=1,
                                            chunksize=100,
                                            passes=10,
                                            alpha='auto',
                                            per_word_topics=True)
#print topics
pprint(lda_model.print_topics())

#save model
doc_lda = lda_model[corpus]

#Print perplexity
print('\nPerplexity: ', lda_model.log_perplexity(corpus))

#Print coherence
coherence_model_lda = CoherenceModel(model=lda_model, texts=data_lemmatized, dictionary=id2word, coherence='u_mass')
coherence_lda = coherence_model_lda.get_coherence()
print('\nCoherence: ', coherence_lda)

vis = pyLDAvis.gensim_models.prepare(lda_model, corpus, id2word)
pyLDAvis.save_html(vis, 'lda_reviews3.html')


#function to compute multiple LDAs with varying topic numbers
#coherence type is u_mass
#returns a list of models and corresponding coherence values
def compute_coherence_values(dictionary, corpus, texts, limit, start=2, step=3):
    coherence_values = []
    model_list = []
    for num_topics in range(start, limit, step):
        model = gensim.models.ldamodel.LdaModel(corpus=corpus, num_topics=num_topics, id2word=id2word)
        model_list.append(model)
        coherencemodel = CoherenceModel(model=model, texts=texts, dictionary=dictionary, coherence='u_mass')
        coherence_values.append(coherencemodel.get_coherence())

    return model_list, coherence_values

#call function
model_list, coherence_values = compute_coherence_values(dictionary=id2word, corpus=corpus, texts=data_lemmatized,
                                                        start=2, limit=40, step=4)

#plot distribution of coherence values for different numbers of topics
limit = 40;
start = 2;
step = 4;
x = range(start, limit, step)
plt.plot(x, coherence_values)
plt.xlabel("Num Topics")
plt.ylabel("Coherence score")
plt.legend(("coherence_values"), loc='best')
plt.show()

for m, um in zip(x, coherence_values):
    print("Num Topics =", m, " has Coherence Value of", round(um, 4))

#choose optimal model depending on coherence
optimal_model = model_list[1]

#show topics of optimal model
model_topics = optimal_model.show_topics(formatted=False)
pprint(optimal_model.print_topics(num_words=10))

#visualize and save as html
vis = pyLDAvis.gensim_models.prepare(optimal_model, corpus, id2word)
pyLDAvis.save_html(vis, 'lda_reviews3.html')


#save topwords of topics to sql
topics = pd.DataFrame(optimal_model.print_topics(num_words = 10))

topics.to_sql("LDA_reviews_topwords3", conn)

#get values for each review corresponding to each topic
all_topics = optimal_model.get_document_topics(corpus, minimum_probability=0.0)
all_topics_csr = gensim.matutils.corpus2csc(all_topics)
all_topics_numpy = all_topics_csr.T.toarray()
all_topics_df = pd.DataFrame(all_topics_numpy)

#save values in sql
all_topics_df.to_sql("LDA_reviews3", conn)
