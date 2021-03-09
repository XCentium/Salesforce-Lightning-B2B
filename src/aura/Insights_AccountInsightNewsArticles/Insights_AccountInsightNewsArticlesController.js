({
    doInit : function(component, event, helper) {
        helper.sendRequest(component, 'c.getAccountInsightNewsArticles', {
            insightId: component.get('v.insight').Id
        }, 'v.newsArticles')
    },
    handleDelete : function(component, event, helper){
        let articles = component.get('v.newsArticles')
        let articleIndex = event.getParam('index')
        let article = articles[articleIndex]
        
        console.log('article', article)
                
        if(article.hasOwnProperty('Id')){
            helper.sendRequest(component, 'c.deleteData', {
                recordIds: [article.Id]
            }, null)
        }
        articles.splice(articleIndex, 1)
        component.set('v.newsArticles', articles)
    },
    addArticle : function(component, event, helper){
        let newsArticles = component.get('v.newsArticles')
        
        newsArticles.push({
            sobjectType: 'AccountInsightNewsArticle',
            Title: '',
            SourceName: '',
            Url: '',
            ImageUrl: ''
        })
        
        component.set('v.newsArticles', newsArticles)
    },
    handleSave: function(component, event, helper){
        let promises = []
        let newsArticles = component.get('v.newsArticles')
        let recordId = component.get('v.recordId')
        let insightId = component.get('v.insight').Id
        
        newsArticles.map(function(newsArticle){
            let action = newsArticle.hasOwnProperty('Id') ? 'c.updateData' : 'c.insertData'
            let url = helper.validateProtocol(newsArticle.Url)
            let imageUrl = helper.validateProtocol(newsArticle.ImageUrl)
            
            newsArticle.Url = url
            newsArticle.ImageUrl = imageUrl
            newsArticle.AccountInsightId = insightId
            newsArticle.AccountId = recordId
            
            promises.push(
                helper.sendRequest(component, action, {
                    records: [newsArticle]
                })
            )
        })
        
        Promise.all(promises)
        
        .then(function(){
            helper.showToast(component, {
                message: 'Articles Upserted!',
                type:'success'
            });
        })
        
        .then(function(){
            helper.goToState(component, {
                type : 'c:Insights_AccountInsights',
                attributes : {
                    recordId: component.get('v.recordId')
                }
            });
        })
    },
    goBack : function(component, event, helper) {
        helper.goToState(component, {
            type : 'c:Insights_AccountInsights',
            attributes : {
                recordId: component.get('v.recordId')
            }
        })
    },
})