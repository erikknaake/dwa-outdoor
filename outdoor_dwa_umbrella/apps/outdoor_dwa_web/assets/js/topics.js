window.topics = {};
window.topics.authStateChanged = {
    subscribers: []
};

window.topics.on = ((topic, subscriber) => {
    if(!window.topics.hasOwnProperty(topic)){
        throw new Error(`Topic "${topic}" not found`);
    }

    window.topics[topic].subscribers.push(subscriber);
});

window.topics.broadcast = (topic, message= {}) => {
    if(!window.topics.hasOwnProperty(topic)){
        throw new Error(`Topic "${topic}" not found`);
    }

    window.topics[topic].subscribers.forEach(subscriber => subscriber(message));
}