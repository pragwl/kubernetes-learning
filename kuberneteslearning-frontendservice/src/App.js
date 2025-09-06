import React, { useState } from 'react';
import './App.css';
import API_CONFIG from './config';

function App() {
  const [postMessage, setPostMessage] = useState('What are you doing?');
  const [postResponseHeaders, setPostResponseHeaders] = useState(null);
  const [getResponse, setGetResponse] = useState([]);
  const [getResponseHeaders, setGetResponseHeaders] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handlePostSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setPostResponseHeaders(null);

    try {
      const response = await fetch(API_CONFIG.POST_MESSAGE_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: postMessage }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const headers = {
        messageId: response.headers.get('messageId'),
        podName: response.headers.get('podName'),
        namespace: response.headers.get('namespace'),
        nodeName: response.headers.get('nodeName'),
        podIP: response.headers.get('podIP'),
        hostIP: response.headers.get('hostIP'),
      };
      setPostResponseHeaders(headers);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  // --- THIS FUNCTION IS CORRECTED ---
  const handleGetMessages = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    // We NO LONGER clear the old data here.
    // This prevents the page layout from collapsing and jumping.

    try {
      const response = await fetch(API_CONFIG.GET_MESSAGES_URL);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const headers = {
        podName: response.headers.get('podName'),
        namespace: response.headers.get('namespace'),
        nodeName: response.headers.get('nodeName'),
        podIP: response.headers.get('podIP'),
        hostIP: response.headers.get('hostIP'),
      };
      
      // We only update the state once we have the new data.
      setGetResponse(data);
      setGetResponseHeaders(headers);
    } catch (error) {
      setError(error.message);
      // If there's an error, we clear the old stale data.
      setGetResponse([]);
      setGetResponseHeaders(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Kubernetes Learning Frontend</h1>
      </header>
      <main>
        {error && <div className="error">Error: {error}</div>}
        {loading && <div className="loading">Loading...</div>}

        <div className="service-section">
          <h2>1. Send a Message (POST to /service1/message)</h2>
          <form onSubmit={handlePostSubmit}>
            <textarea
              value={postMessage}
              onChange={(e) => setPostMessage(e.target.value)}
              rows="3"
            />
            <button type="submit">Send Message</button>
          </form>
          {postResponseHeaders && (
            <div className="response-container">
              <h3>Response Headers:</h3>
              <pre className="scrollable-pre">{JSON.stringify(postResponseHeaders, null, 2)}</pre>
            </div>
          )}
        </div>

        <div className="service-section">
          <h2>2. Get All Messages (GET from /service2/message)</h2>
          {/* --- THIS BUTTON IS CORRECTED --- */}
          <button type="button" onClick={(e) => handleGetMessages(e)}>
            Get Messages
          </button>
          {getResponseHeaders && (
            <div className="response-container">
              <h3>Response Headers:</h3>
              <pre className="scrollable-pre">{JSON.stringify(getResponseHeaders, null, 2)}</pre>
            </div>
          )}
          {getResponse.length > 0 && (
            <div className="response-container">
              <h3>Response Body:</h3>
              <pre className="scrollable-pre">{JSON.stringify(getResponse, null, 2)}</pre>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;