// Get SEO keywords for a location
async function getKeywordsByLocation(pool, city, state) {
  try {
    const result = await pool.query(
      `SELECT * FROM keywords
       WHERE (city = $1 OR state = $2)
       ORDER BY search_volume DESC
       LIMIT 20`,
      [city, state]
    );
    
    return result.rows;
  } catch (error) {
    console.error('Keyword fetch error:', error);
    return [];
  }
}

// Get top keywords by search volume
async function getTopKeywords(pool, limit = 50) {
  try {
    const result = await pool.query(
      `SELECT * FROM keywords
       ORDER BY search_volume DESC
       LIMIT $1`,
      [limit]
    );
    
    return result.rows;
  } catch (error) {
    console.error('Top keywords error:', error);
    return [];
  }
}

// Track keyword search
async function trackKeywordSearch(pool, keywordId) {
  try {
    await pool.query(
      `UPDATE keywords 
       SET search_count = search_count + 1, last_searched = CURRENT_TIMESTAMP
       WHERE id = $1`,
      [keywordId]
    );
    return true;
  } catch (error) {
    console.error('Keyword tracking error:', error);
    return false;
  }
}

module.exports = {
  getKeywordsByLocation,
  getTopKeywords,
  trackKeywordSearch
};
