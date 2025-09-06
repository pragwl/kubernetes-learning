const API_CONFIG = {
  // During the build, Webpack replaces this with the value from .env.production
  POST_MESSAGE_URL: process.env.REACT_APP_POST_MESSAGE_URL,
  GET_MESSAGES_URL: process.env.REACT_APP_GET_MESSAGES_URL
};

export default API_CONFIG;