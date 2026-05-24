import 'package:flutter/material.dart';
import 'models.dart';

class Curriculum {
  static List<World> get worlds => [_world1, _world2, _world3];

  // Resets all in-memory world and level state back to defaults.
  // Call this alongside StorageService.clearAll() to do a full progress reset.
  static void resetProgress() {
    for (int wi = 0; wi < worlds.length; wi++) {
      worlds[wi].isUnlocked = wi == 0;
      for (int li = 0; li < worlds[wi].levels.length; li++) {
        worlds[wi].levels[li].stars = 0;
        worlds[wi].levels[li].bestScore = 0;
        worlds[wi].levels[li].isUnlocked = wi == 0 && li == 0;
      }
    }
  }

  // ── WORLD 1 — Market Basics ───────────────────────────────────────────────
  static final World _world1 = World(
    index: 0,
    title: 'Market Basics',
    subtitle: 'How stocks & markets work',
    imagePath: 'assets/images/world1.png',
    difficulty: Difficulty.beginner,
    accentColor: const Color(0xFF00FFB2),
    isUnlocked: true,
    levels: [
      Level(
        id: 'w1l0',
        title: 'What Is a Stock?',
        subtitle: 'Ownership & shares',
        worldIndex: 0,
        levelIndex: 0,
        isUnlocked: true,
        questions: _w1l0Questions,
      ),
      Level(
        id: 'w1l1',
        title: 'How Exchanges Work',
        subtitle: 'NYSE, NASDAQ & trading',
        worldIndex: 0,
        levelIndex: 1,
        questions: _w1l1Questions,
      ),
      Level(
        id: 'w1l2',
        title: 'Bull & Bear Markets',
        subtitle: 'Market cycles',
        worldIndex: 0,
        levelIndex: 2,
        questions: _w1l2Questions,
      ),
      Level(
        id: 'w1l3',
        title: 'Market Indices',
        subtitle: 'S&P 500, Dow, NASDAQ',
        worldIndex: 0,
        levelIndex: 3,
        questions: _w1l3Questions,
      ),
      Level(
        id: 'w1l4',
        title: 'Orders & Trades',
        subtitle: 'Market vs limit orders',
        worldIndex: 0,
        levelIndex: 4,
        questions: _w1l4Questions,
      ),
    ],
  );

  // ── WORLD 2 — Reading the Tape ────────────────────────────────────────────
  static final World _world2 = World(
    index: 1,
    title: 'Reading the Tape',
    subtitle: 'Charts, candlesticks & price action',
    imagePath: 'assets/images/world2.png',
    difficulty: Difficulty.beginner,
    accentColor: const Color(0xFF4CC9F0),
    levels: [
      Level(
        id: 'w2l0',
        title: 'Candlestick Basics',
        subtitle: 'Open, high, low, close',
        worldIndex: 1,
        levelIndex: 0,
        questions: _w2l0Questions,
      ),
      Level(
        id: 'w2l1',
        title: 'Volume & Momentum',
        subtitle: 'What volume tells you',
        worldIndex: 1,
        levelIndex: 1,
        questions: _w2l1Questions,
      ),
      Level(
        id: 'w2l2',
        title: 'Support & Resistance',
        subtitle: 'Key price levels',
        worldIndex: 1,
        levelIndex: 2,
        questions: _w2l2Questions,
      ),
      Level(
        id: 'w2l3',
        title: 'Moving Averages',
        subtitle: 'SMA, EMA & crossovers',
        worldIndex: 1,
        levelIndex: 3,
        questions: _w2l3Questions,
      ),
      Level(
        id: 'w2l4',
        title: 'Chart Patterns',
        subtitle: 'H&S, triangles & flags',
        worldIndex: 1,
        levelIndex: 4,
        questions: _w2l4Questions,
      ),
    ],
  );

  // ── WORLD 3 — Fundamentals ────────────────────────────────────────────────
  static final World _world3 = World(
    index: 2,
    title: 'Fundamentals',
    subtitle: 'Value, earnings & financial health',
    imagePath: 'assets/images/world3.png',
    difficulty: Difficulty.intermediate,
    accentColor: const Color(0xFFFFD166),
    levels: [
      Level(
        id: 'w3l0',
        title: 'Reading Earnings',
        subtitle: 'EPS, revenue & guidance',
        worldIndex: 2,
        levelIndex: 0,
        questions: _w3l0Questions,
      ),
      Level(
        id: 'w3l1',
        title: 'Valuation Ratios',
        subtitle: 'P/E, P/B, P/S & EV/EBITDA',
        worldIndex: 2,
        levelIndex: 1,
        questions: _w3l1Questions,
      ),
      Level(
        id: 'w3l2',
        title: 'Balance Sheet',
        subtitle: 'Assets, liabilities & equity',
        worldIndex: 2,
        levelIndex: 2,
        questions: _w3l2Questions,
      ),
      Level(
        id: 'w3l3',
        title: 'Cash Flow',
        subtitle: 'FCF & capital allocation',
        worldIndex: 2,
        levelIndex: 3,
        questions: _w3l3Questions,
      ),
      Level(
        id: 'w3l4',
        title: 'Sector Analysis',
        subtitle: 'Cyclical vs defensive',
        worldIndex: 2,
        levelIndex: 4,
        questions: _w3l4Questions,
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // WORLD 1 QUESTIONS
  // ════════════════════════════════════════════════════════════════════════════

  // ── W1 L0 — What Is a Stock? ──────────────────────────────────────────────
  static final List<StockQuestion> _w1l0Questions = [
    StockQuestion(
      id: 'w1l0q0',
      type: QuestionType.multipleChoice,
      concept: 'Stock Ownership',
      prompt: 'When you buy a share of a company, you become a:',
      options: [
        'Creditor',
        'Part-owner (shareholder)',
        'Employee',
        'Bond holder'
      ],
      correctIndex: 1,
      briefExplanation:
          'Buying a share makes you a part-owner (shareholder) of the company, entitling you to a portion of its profits and assets.',
      sagePrompt:
          'Explain what it means to own a stock and what rights shareholders have.',
    ),
    StockQuestion(
      id: 'w1l0q1',
      type: QuestionType.trueFalse,
      concept: 'Limited Liability',
      prompt:
          'If a company goes bankrupt, shareholders can lose more than their original investment.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Limited liability protects shareholders — the most you can lose is what you invested, not your personal assets.',
      sagePrompt: 'Explain limited liability and why it matters for investors.',
    ),
    StockQuestion(
      id: 'w1l0q2',
      type: QuestionType.multipleChoice,
      concept: 'Market Cap',
      prompt:
          'A company has 10 million shares priced at \$50 each. What is its market cap?',
      options: ['\$50 million', '\$500 million', '\$5 billion', '\$50 billion'],
      correctIndex: 1,
      briefExplanation:
          'Market cap = share price × total shares outstanding. 10,000,000 × \$50 = \$500,000,000.',
      sagePrompt:
          'Explain how market capitalization is calculated and what it tells investors.',
    ),
    StockQuestion(
      id: 'w1l0q3',
      type: QuestionType.multipleChoice,
      concept: 'IPO',
      prompt: 'What does IPO stand for?',
      options: [
        'Internal Pricing Operation',
        'Initial Public Offering',
        'Investor Purchase Order',
        'Index Price Oscillator'
      ],
      correctIndex: 1,
      briefExplanation:
          'IPO stands for Initial Public Offering — the first time a private company sells shares to the general public.',
      sagePrompt: 'Explain what an IPO is and why companies go public.',
    ),
    StockQuestion(
      id: 'w1l0q4',
      type: QuestionType.multipleChoice,
      concept: 'Dividends',
      prompt: 'A dividend is best described as:',
      options: [
        'A loan from the company to shareholders',
        'A portion of company profits paid to shareholders',
        'A penalty for selling shares early',
        'A fee charged by the stock exchange'
      ],
      correctIndex: 1,
      briefExplanation:
          'Dividends are a share of a company\'s profits distributed to shareholders, usually paid quarterly.',
      sagePrompt:
          'Explain dividends and how they contribute to total investment returns.',
    ),
    StockQuestion(
      id: 'w1l0q5',
      type: QuestionType.trueFalse,
      concept: 'Voting Rights',
      prompt:
          'All shareholders of a company always have equal voting rights per share.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Many companies issue multiple share classes with different voting rights. For example, Google\'s Class B shares carry 10 votes each, while Class A shares carry just one.',
      sagePrompt:
          'Explain dual-class share structures and why some companies use them.',
    ),
    StockQuestion(
      id: 'w1l0q6',
      type: QuestionType.multipleChoice,
      concept: 'Stock Split',
      prompt:
          'You own 10 shares at \$400 each. Apple announces a 4-for-1 stock split. What do you now hold?',
      options: [
        '10 shares at \$100',
        '40 shares at \$100',
        '40 shares at \$400',
        '10 shares at \$1,600'
      ],
      correctIndex: 1,
      briefExplanation:
          'A 4-for-1 split multiplies shares by 4 and divides price by 4. Your 10 shares at \$400 become 40 shares at \$100. Total value is unchanged.',
      sagePrompt: 'Explain stock splits and why companies do them.',
    ),
    StockQuestion(
      id: 'w1l0q7',
      type: QuestionType.multipleChoice,
      concept: 'Share Dilution',
      prompt:
          'When a company issues new shares, what happens to existing shareholders?',
      options: [
        'Their shares increase in value automatically',
        'Their ownership percentage decreases',
        'They receive a cash payment',
        'Nothing changes for them'
      ],
      correctIndex: 1,
      briefExplanation:
          'Issuing new shares dilutes existing shareholders — their percentage ownership shrinks unless they buy more shares proportionally.',
      sagePrompt:
          'Explain share dilution and its effect on existing investors.',
    ),
    StockQuestion(
      id: 'w1l0q8',
      type: QuestionType.multipleChoice,
      concept: 'Capital Structure',
      prompt: 'In a bankruptcy liquidation, who gets paid first?',
      options: [
        'Common shareholders',
        'Preferred shareholders',
        'Bond holders (creditors)',
        'Employees'
      ],
      correctIndex: 2,
      briefExplanation:
          'The payment priority in bankruptcy is: secured creditors → bond holders → preferred shareholders → common shareholders. Common shareholders are last.',
      sagePrompt:
          'Explain the capital structure waterfall and why bond holders rank above shareholders.',
    ),
    StockQuestion(
      id: 'w1l0q9',
      type: QuestionType.trueFalse,
      concept: 'Stock Market',
      prompt:
          'Stock markets are zero-sum — for every investor who profits, another must lose the same amount.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Stock markets are positive-sum over time. As companies grow and generate profits, the total value of the market increases, allowing all investors to gain.',
      sagePrompt:
          'Explain why stock investing is not zero-sum and how market value is created.',
    ),
  ];

  // ── W1 L1 — How Exchanges Work ────────────────────────────────────────────
  static final List<StockQuestion> _w1l1Questions = [
    StockQuestion(
      id: 'w1l1q0',
      type: QuestionType.multipleChoice,
      concept: 'Stock Exchange',
      prompt: 'What is the primary role of a stock exchange like the NYSE?',
      options: [
        'To lend money to companies',
        'To provide a marketplace where buyers and sellers trade shares',
        'To set the prices companies can charge for products',
        'To regulate interest rates'
      ],
      correctIndex: 1,
      briefExplanation:
          'A stock exchange provides a regulated marketplace where buyers and sellers can trade shares efficiently and transparently.',
      sagePrompt:
          'Explain what a stock exchange does and why regulated markets matter.',
    ),
    StockQuestion(
      id: 'w1l1q1',
      type: QuestionType.multipleChoice,
      concept: 'NYSE vs NASDAQ',
      prompt:
          'Which exchange is known as a fully electronic marketplace with no physical trading floor?',
      options: [
        'NYSE',
        'NASDAQ',
        'London Stock Exchange',
        'Tokyo Stock Exchange'
      ],
      correctIndex: 1,
      briefExplanation:
          'NASDAQ was the world\'s first electronic stock exchange. The NYSE still maintains a physical trading floor in New York.',
      sagePrompt:
          'Explain the difference between NYSE and NASDAQ and which companies tend to list on each.',
    ),
    StockQuestion(
      id: 'w1l1q2',
      type: QuestionType.trueFalse,
      concept: 'Market Hours',
      prompt: 'The US stock market is open 24 hours a day, 7 days a week.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'US markets have regular trading hours of 9:30 AM to 4:00 PM ET on weekdays. Pre-market and after-hours sessions exist but have less liquidity.',
      sagePrompt:
          'Explain US market trading hours and what happens in pre-market and after-hours sessions.',
    ),
    StockQuestion(
      id: 'w1l1q3',
      type: QuestionType.multipleChoice,
      concept: 'Market Maker',
      prompt: 'A market maker\'s primary function is to:',
      options: [
        'Set government regulations for trading',
        'Provide liquidity by always being ready to buy or sell shares',
        'Audit company financial statements',
        'Manage investor portfolios'
      ],
      correctIndex: 1,
      briefExplanation:
          'Market makers provide liquidity by quoting both a buy (bid) and sell (ask) price, ensuring there is always a counterparty for trades.',
      sagePrompt:
          'Explain what market makers do and why they are important for liquid markets.',
    ),
    StockQuestion(
      id: 'w1l1q4',
      type: QuestionType.multipleChoice,
      concept: 'Bid-Ask Spread',
      prompt: 'The bid-ask spread represents:',
      options: [
        'The difference between a stock\'s 52-week high and low',
        'The difference between the highest buy price and lowest sell price',
        'The annual fee charged by brokers',
        'The gap between a stock\'s book value and market value'
      ],
      correctIndex: 1,
      briefExplanation:
          'The bid-ask spread is the difference between the highest price a buyer will pay (bid) and the lowest price a seller will accept (ask). It is a transaction cost.',
      sagePrompt:
          'Explain the bid-ask spread and how it affects the cost of trading.',
    ),
    StockQuestion(
      id: 'w1l1q5',
      type: QuestionType.trueFalse,
      concept: 'Ticker Symbol',
      prompt:
          'Two different companies can have the same ticker symbol on the same exchange.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Ticker symbols are unique identifiers on each exchange. No two companies can share the same ticker on the same exchange.',
      sagePrompt:
          'Explain ticker symbols and how they uniquely identify companies on exchanges.',
    ),
    StockQuestion(
      id: 'w1l1q6',
      type: QuestionType.multipleChoice,
      concept: 'Settlement',
      prompt:
          'When you buy a stock, the standard US settlement period (T+2) means the trade settles in:',
      options: ['2 minutes', '2 hours', '2 business days', '2 weeks'],
      correctIndex: 2,
      briefExplanation:
          'T+2 means the trade settles 2 business days after execution. The SEC moved US markets to T+1 in 2024, but T+2 was the standard for many years.',
      sagePrompt: 'Explain trade settlement and why it matters for investors.',
    ),
    StockQuestion(
      id: 'w1l1q7',
      type: QuestionType.multipleChoice,
      concept: 'Circuit Breaker',
      prompt: 'A market circuit breaker is triggered when:',
      options: [
        'A company files for bankruptcy',
        'The market drops sharply within a short period, pausing trading temporarily',
        'A stock\'s price rises more than 10% in a day',
        'A broker runs out of shares to sell'
      ],
      correctIndex: 1,
      briefExplanation:
          'Circuit breakers pause trading when markets fall sharply (e.g. 7%, 13%, or 20% in a day) to prevent panic selling and allow investors to reassess.',
      sagePrompt:
          'Explain market circuit breakers and give a historical example of when they were triggered.',
    ),
    StockQuestion(
      id: 'w1l1q8',
      type: QuestionType.multipleChoice,
      concept: 'Liquidity',
      prompt: 'A highly liquid stock is one that:',
      options: [
        'Has a very high share price',
        'Can be bought or sold quickly without significantly moving its price',
        'Pays a high dividend',
        'Is issued by a government'
      ],
      correctIndex: 1,
      briefExplanation:
          'Liquidity means you can easily enter or exit a position. High-volume stocks like Apple or Microsoft are highly liquid because millions of shares trade daily.',
      sagePrompt:
          'Explain liquidity and why it matters when choosing stocks to trade.',
    ),
    StockQuestion(
      id: 'w1l1q9',
      type: QuestionType.trueFalse,
      concept: 'OTC Markets',
      prompt:
          'All publicly traded stocks must be listed on a major exchange like NYSE or NASDAQ.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Many stocks trade Over-the-Counter (OTC) on platforms like OTC Markets Group, outside of formal exchanges. These are often smaller or foreign companies.',
      sagePrompt:
          'Explain OTC markets and how they differ from listed exchanges.',
    ),
  ];

  // ── W1 L2 — Bull & Bear Markets ───────────────────────────────────────────
  static final List<StockQuestion> _w1l2Questions = [
    StockQuestion(
      id: 'w1l2q0',
      type: QuestionType.multipleChoice,
      concept: 'Bull Market',
      prompt:
          'A bull market is generally defined as a period where stock prices have risen by at least:',
      options: [
        '5% from recent lows',
        '10% from recent lows',
        '20% from recent lows',
        '50% from recent lows'
      ],
      correctIndex: 2,
      briefExplanation:
          'A bull market is conventionally defined as a 20% or more rise from recent lows, sustained over time. It reflects investor optimism and economic growth.',
      sagePrompt:
          'Explain what defines a bull market and how long they typically last historically.',
    ),
    StockQuestion(
      id: 'w1l2q1',
      type: QuestionType.multipleChoice,
      concept: 'Bear Market',
      prompt:
          'A bear market is defined as a decline of at least 20% from recent highs lasting:',
      options: [
        'At least one day',
        'At least two months',
        'At least one year',
        'Exactly six months'
      ],
      correctIndex: 1,
      briefExplanation:
          'A bear market is a 20%+ decline from recent highs sustained over at least two months. It signals a prolonged downturn driven by pessimism or economic weakness.',
      sagePrompt:
          'Explain what defines a bear market and historical examples like 2008 or 2020.',
    ),
    StockQuestion(
      id: 'w1l2q2',
      type: QuestionType.trueFalse,
      concept: 'Market Correction',
      prompt:
          'A market correction (a 10% decline) is considered the same as a bear market.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'A correction is a 10–20% decline and is shorter and less severe than a bear market. Corrections are common and happen roughly once a year on average.',
      sagePrompt:
          'Explain the difference between a market correction and a bear market.',
    ),
    StockQuestion(
      id: 'w1l2q3',
      type: QuestionType.multipleChoice,
      concept: 'Economic Cycle',
      prompt:
          'Which phase of the economic cycle typically accompanies a bull market?',
      options: ['Recession', 'Contraction', 'Expansion', 'Trough'],
      correctIndex: 2,
      briefExplanation:
          'Bull markets typically occur during economic expansions when GDP is growing, unemployment is falling, and corporate profits are rising.',
      sagePrompt:
          'Explain how the economic cycle relates to bull and bear markets.',
    ),
    StockQuestion(
      id: 'w1l2q4',
      type: QuestionType.multipleChoice,
      concept: 'Recession',
      prompt: 'A recession is technically defined as:',
      options: [
        'One quarter of negative GDP growth',
        'Two consecutive quarters of negative GDP growth',
        'A 20% drop in the stock market',
        'Unemployment rising above 10%'
      ],
      correctIndex: 1,
      briefExplanation:
          'The traditional definition of a recession is two consecutive quarters of negative GDP growth, though the NBER uses a broader set of indicators.',
      sagePrompt:
          'Explain what a recession is and how it affects the stock market.',
    ),
    StockQuestion(
      id: 'w1l2q5',
      type: QuestionType.trueFalse,
      concept: 'Bear Market Timing',
      prompt:
          'Investors can reliably time the market to sell before bear markets and buy before bull markets.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Market timing is notoriously difficult even for professionals. Missing just the 10 best trading days in a decade can cut returns by more than half.',
      sagePrompt:
          'Explain why market timing is so difficult and what research shows about trying to time markets.',
    ),
    StockQuestion(
      id: 'w1l2q6',
      type: QuestionType.multipleChoice,
      concept: 'Volatility',
      prompt: 'The VIX index is known as the "fear gauge" because it measures:',
      options: [
        'The number of stocks hitting new highs',
        'Expected market volatility over the next 30 days',
        'The ratio of advancing to declining stocks',
        'The average P/E ratio of the S&P 500'
      ],
      correctIndex: 1,
      briefExplanation:
          'The VIX measures implied volatility of S&P 500 options over the next 30 days. High VIX means investors expect large price swings — usually during fear or uncertainty.',
      sagePrompt:
          'Explain what the VIX measures and how it behaves during market downturns.',
    ),
    StockQuestion(
      id: 'w1l2q7',
      type: QuestionType.multipleChoice,
      concept: 'Secular vs Cyclical',
      prompt: 'A secular bull market refers to:',
      options: [
        'A bull market driven by religious sentiment',
        'A long-term uptrend lasting many years or decades',
        'A short-term rally within a bear market',
        'A rally limited to a specific sector'
      ],
      correctIndex: 1,
      briefExplanation:
          'A secular market trend lasts many years (10–25 years). Secular bull markets like 1982–2000 and 2009–present contain multiple shorter cyclical bear markets within them.',
      sagePrompt:
          'Explain the difference between secular and cyclical market trends.',
    ),
    StockQuestion(
      id: 'w1l2q8',
      type: QuestionType.trueFalse,
      concept: 'Bear Market Recovery',
      prompt:
          'Historically, the US stock market has always recovered from bear markets and gone on to new highs.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Every US bear market in history has eventually been followed by a recovery to new highs. The S&P 500 has never permanently lost value over any 20-year period.',
      sagePrompt:
          'Show historical bear market recoveries and how long each took to recover.',
    ),
    StockQuestion(
      id: 'w1l2q9',
      type: QuestionType.multipleChoice,
      concept: 'Investor Sentiment',
      prompt: 'Which sentiment indicator suggests markets may be near a top?',
      options: [
        'Extreme fear readings on the Fear & Greed Index',
        'Extreme greed readings on the Fear & Greed Index',
        'Low trading volume across major exchanges',
        'Rising bond yields with falling stock prices'
      ],
      correctIndex: 1,
      briefExplanation:
          'Extreme greed often signals that markets are overextended and due for a pullback. Contrarian investors often see extreme greed as a warning sign.',
      sagePrompt:
          'Explain sentiment indicators and contrarian investing strategies.',
    ),
  ];

  // ── W1 L3 — Market Indices ────────────────────────────────────────────────
  static final List<StockQuestion> _w1l3Questions = [
    StockQuestion(
      id: 'w1l3q0',
      type: QuestionType.multipleChoice,
      concept: 'S&P 500',
      prompt: 'The S&P 500 index tracks:',
      options: [
        'The 500 largest companies by revenue',
        '500 large-cap US companies selected by a committee',
        'All companies listed on the NYSE',
        'The 500 most traded stocks in the US'
      ],
      correctIndex: 1,
      briefExplanation:
          'The S&P 500 tracks 500 large-cap US companies selected by S&P\'s index committee based on market cap, liquidity, and financial viability.',
      sagePrompt:
          'Explain what the S&P 500 is and why it is considered the best benchmark for US stocks.',
    ),
    StockQuestion(
      id: 'w1l3q1',
      type: QuestionType.multipleChoice,
      concept: 'Dow Jones',
      prompt:
          'The Dow Jones Industrial Average (DJIA) is a price-weighted index. This means:',
      options: [
        'Companies are weighted by their market cap',
        'Higher-priced stocks have more influence on the index',
        'All 30 stocks are weighted equally',
        'Stocks are weighted by their trading volume'
      ],
      correctIndex: 1,
      briefExplanation:
          'The DJIA is price-weighted, so a \$500 stock has 5x more impact than a \$100 stock regardless of company size. This is why stock splits can significantly change a stock\'s DJIA weighting.',
      sagePrompt:
          'Explain the difference between price-weighted and market-cap-weighted indices.',
    ),
    StockQuestion(
      id: 'w1l3q2',
      type: QuestionType.multipleChoice,
      concept: 'NASDAQ Composite',
      prompt: 'The NASDAQ Composite is heavily weighted toward which sector?',
      options: ['Energy', 'Financials', 'Technology', 'Healthcare'],
      correctIndex: 2,
      briefExplanation:
          'The NASDAQ Composite is dominated by technology companies. Apple, Microsoft, Amazon, and Alphabet together make up a large percentage of its weight.',
      sagePrompt:
          'Explain the NASDAQ Composite and its technology sector concentration.',
    ),
    StockQuestion(
      id: 'w1l3q3',
      type: QuestionType.trueFalse,
      concept: 'Index Weighting',
      prompt:
          'In the S&P 500, every company has an equal impact on the index\'s performance.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'The S&P 500 is market-cap weighted. Larger companies like Apple or Microsoft have far more influence than smaller companies. Apple alone can move the S&P 500.',
      sagePrompt:
          'Explain market-cap weighting and how the largest S&P 500 companies dominate the index.',
    ),
    StockQuestion(
      id: 'w1l3q4',
      type: QuestionType.multipleChoice,
      concept: 'Russell 2000',
      prompt: 'The Russell 2000 index tracks:',
      options: [
        'The 2,000 largest US companies',
        '2,000 small-cap US companies',
        'The top 2,000 global companies',
        '2,000 dividend-paying stocks'
      ],
      correctIndex: 1,
      briefExplanation:
          'The Russell 2000 tracks 2,000 small-cap US companies. It is widely used as a benchmark for small-cap performance and is more sensitive to domestic economic conditions.',
      sagePrompt:
          'Explain the Russell 2000 and how small-cap stocks differ from large-caps.',
    ),
    StockQuestion(
      id: 'w1l3q5',
      type: QuestionType.multipleChoice,
      concept: 'Index Fund',
      prompt: 'An index fund that tracks the S&P 500 aims to:',
      options: [
        'Beat the S&P 500 by picking the best stocks',
        'Match the performance of the S&P 500',
        'Only invest in the top 10 S&P 500 companies',
        'Short the S&P 500 to profit from declines'
      ],
      correctIndex: 1,
      briefExplanation:
          'Index funds passively replicate an index by holding all (or most) of its components. They aim to match, not beat, the index performance.',
      sagePrompt:
          'Explain index funds and the evidence for passive investing vs active stock picking.',
    ),
    StockQuestion(
      id: 'w1l3q6',
      type: QuestionType.trueFalse,
      concept: 'Benchmark',
      prompt:
          'A fund manager who returns 8% in a year when the S&P 500 returns 15% has outperformed.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Although 8% is a positive return, it underperforms the benchmark (S&P 500) by 7 percentage points. Relative performance against the benchmark is what matters for fund evaluation.',
      sagePrompt:
          'Explain benchmarking and why beating the index is the standard for measuring fund manager performance.',
    ),
    StockQuestion(
      id: 'w1l3q7',
      type: QuestionType.multipleChoice,
      concept: 'Global Indices',
      prompt:
          'Which index tracks the largest companies across developed markets globally (excluding the US)?',
      options: ['FTSE 100', 'MSCI EAFE', 'Nikkei 225', 'DAX'],
      correctIndex: 1,
      briefExplanation:
          'The MSCI EAFE (Europe, Australasia, Far East) is the primary benchmark for international developed market stocks, excluding North America.',
      sagePrompt:
          'Explain global market indices and why international diversification matters.',
    ),
    StockQuestion(
      id: 'w1l3q8',
      type: QuestionType.multipleChoice,
      concept: 'Index Rebalancing',
      prompt:
          'When a company is added to the S&P 500, what typically happens to its stock price?',
      options: [
        'It usually falls because of increased scrutiny',
        'It usually rises because index funds must buy it',
        'It is unaffected since index inclusion is symbolic',
        'It is halted from trading for 24 hours'
      ],
      correctIndex: 1,
      briefExplanation:
          'When a stock joins the S&P 500, every S&P 500 index fund must buy it. This surge in demand typically causes the stock price to rise — known as the "index inclusion effect."',
      sagePrompt:
          'Explain index rebalancing and the price impact of S&P 500 inclusions.',
    ),
    StockQuestion(
      id: 'w1l3q9',
      type: QuestionType.trueFalse,
      concept: 'Total Return',
      prompt:
          'A stock index that tracks only price changes (not dividends) overstates the total return investors actually receive.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Price-only indices understate total returns. Total return indices reinvest dividends, which historically account for roughly 40% of the S&P 500\'s long-term gains.',
      sagePrompt:
          'Explain the difference between price return and total return and why dividends matter for long-term investors.',
    ),
  ];

  // ── W1 L4 — Orders & Trades ───────────────────────────────────────────────
  static final List<StockQuestion> _w1l4Questions = [
    StockQuestion(
      id: 'w1l4q0',
      type: QuestionType.multipleChoice,
      concept: 'Market Order',
      prompt: 'A market order guarantees:',
      options: [
        'Execution at a specific price',
        'Execution at the best available current price',
        'Execution only if the price rises',
        'Execution within 24 hours'
      ],
      correctIndex: 1,
      briefExplanation:
          'A market order executes immediately at the best available price. It guarantees execution but not the exact price, especially in volatile or illiquid markets.',
      sagePrompt:
          'Explain market orders and when they are most appropriate to use.',
    ),
    StockQuestion(
      id: 'w1l4q1',
      type: QuestionType.multipleChoice,
      concept: 'Limit Order',
      prompt:
          'You place a limit buy order for AAPL at \$150 when it is trading at \$155. The order will execute:',
      options: [
        'Immediately at \$155',
        'Only if AAPL drops to \$150 or below',
        'Only if AAPL rises to \$160',
        'Never, because limit orders can only be used to sell'
      ],
      correctIndex: 1,
      briefExplanation:
          'A limit buy order only executes at your specified price or better (lower). If AAPL never reaches \$150, the order remains open or expires unfilled.',
      sagePrompt:
          'Explain limit orders and how they give investors price control.',
    ),
    StockQuestion(
      id: 'w1l4q2',
      type: QuestionType.multipleChoice,
      concept: 'Stop-Loss Order',
      prompt:
          'A stop-loss order placed at \$90 on a stock you bought at \$100 will:',
      options: [
        'Lock in a \$10 profit',
        'Sell the stock if it falls to \$90, limiting your loss',
        'Buy more shares if the price drops to \$90',
        'Automatically cancel if the stock rises above \$100'
      ],
      correctIndex: 1,
      briefExplanation:
          'A stop-loss order becomes a market sell order when the price hits your stop price (\$90), automatically limiting your loss to around \$10 per share.',
      sagePrompt:
          'Explain stop-loss orders and how they are used for risk management.',
    ),
    StockQuestion(
      id: 'w1l4q3',
      type: QuestionType.trueFalse,
      concept: 'Day Order',
      prompt:
          'A day order that is not executed by market close is automatically cancelled.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Day orders expire at the end of the trading day if not filled. Good-Till-Cancelled (GTC) orders remain active until filled or manually cancelled.',
      sagePrompt: 'Explain the difference between day orders and GTC orders.',
    ),
    StockQuestion(
      id: 'w1l4q4',
      type: QuestionType.multipleChoice,
      concept: 'Short Selling',
      prompt: 'To short sell a stock, you first need to:',
      options: [
        'Own the stock outright',
        'Borrow shares from a broker',
        'Buy a put option',
        'File a form with the SEC'
      ],
      correctIndex: 1,
      briefExplanation:
          'Short selling requires borrowing shares from a broker to sell them. You later buy them back (hopefully at a lower price) and return them to the lender.',
      sagePrompt: 'Explain the mechanics of short selling and its risks.',
    ),
    StockQuestion(
      id: 'w1l4q5',
      type: QuestionType.multipleChoice,
      concept: 'Margin Trading',
      prompt: 'Trading on margin means:',
      options: [
        'Only trading stocks with high profit margins',
        'Borrowing money from your broker to buy more shares than you could with cash alone',
        'Buying stocks at a discount to their book value',
        'Trading during the margin hours before market open'
      ],
      correctIndex: 1,
      briefExplanation:
          'Margin trading lets you borrow money from your broker to increase your buying power. It amplifies both gains and losses and involves paying interest on the borrowed amount.',
      sagePrompt:
          'Explain margin trading, leverage, and the risks of a margin call.',
    ),
    StockQuestion(
      id: 'w1l4q6',
      type: QuestionType.trueFalse,
      concept: 'Slippage',
      prompt:
          'Slippage occurs when you receive a worse price than expected when executing a trade.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Slippage is the difference between the expected trade price and the actual executed price. It is most common with large orders, market orders, or in illiquid stocks.',
      sagePrompt:
          'Explain slippage and how to minimize it when executing trades.',
    ),
    StockQuestion(
      id: 'w1l4q7',
      type: QuestionType.multipleChoice,
      concept: 'Order Book',
      prompt: 'The order book shows:',
      options: [
        'A company\'s financial statements',
        'All pending buy and sell orders at various price levels',
        'The history of trades that have already executed',
        'A broker\'s list of recommended stocks'
      ],
      correctIndex: 1,
      briefExplanation:
          'The order book displays all outstanding limit buy orders (bids) and limit sell orders (asks) at each price level, giving visibility into supply and demand.',
      sagePrompt: 'Explain the order book and how to read market depth.',
    ),
    StockQuestion(
      id: 'w1l4q8',
      type: QuestionType.multipleChoice,
      concept: 'After-Hours Trading',
      prompt: 'After-hours trading is generally characterized by:',
      options: [
        'Higher volume and tighter spreads than regular hours',
        'Lower volume and wider bid-ask spreads',
        'The same conditions as regular market hours',
        'No price movement since markets are closed'
      ],
      correctIndex: 1,
      briefExplanation:
          'After-hours trading has significantly lower volume and wider spreads, meaning prices can move sharply on small orders and execution quality is typically worse.',
      sagePrompt:
          'Explain after-hours trading risks and why earnings announcements often cause big after-hours moves.',
    ),
    StockQuestion(
      id: 'w1l4q9',
      type: QuestionType.trueFalse,
      concept: 'Pattern Day Trader',
      prompt:
          'In the US, a pattern day trader must maintain at least \$25,000 in their account.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'FINRA rules require pattern day traders (those who execute 4+ day trades in 5 business days) to maintain a minimum of \$25,000 in their margin account.',
      sagePrompt:
          'Explain the pattern day trader rule and its implications for active traders.',
    ),
  ];

  // ════════════════════════════════════════════════════════════════════════════
  // WORLD 2 QUESTIONS
  // ════════════════════════════════════════════════════════════════════════════

  // ── W2 L0 — Candlestick Basics ────────────────────────────────────────────
  static final List<StockQuestion> _w2l0Questions = [
    StockQuestion(
      id: 'w2l0q0',
      type: QuestionType.multipleChoice,
      concept: 'Candlestick',
      prompt: 'A candlestick\'s "body" represents:',
      options: [
        'The high and low prices for the period',
        'The range between opening and closing prices',
        'The average price for the day',
        'The trading volume for the period'
      ],
      correctIndex: 1,
      briefExplanation:
          'The body of a candlestick shows the range between the open and close. A green/white body means close > open (bullish); red/black means close < open (bearish).',
      sagePrompt:
          'Explain candlestick anatomy and what each part tells you about price action.',
    ),
    StockQuestion(
      id: 'w2l0q1',
      type: QuestionType.multipleChoice,
      concept: 'Candlestick Wicks',
      prompt: 'The upper wick (shadow) of a candlestick shows:',
      options: [
        'The closing price',
        'The highest price reached during the period',
        'The average of open and close',
        'The previous day\'s closing price'
      ],
      correctIndex: 1,
      briefExplanation:
          'The upper wick extends from the body top to the period\'s highest price. The lower wick extends to the lowest price. Together they show the full price range.',
      sagePrompt:
          'Explain candlestick wicks and what long wicks signal about buyer/seller battles.',
    ),
    StockQuestion(
      id: 'w2l0q2',
      type: QuestionType.trueFalse,
      concept: 'Bullish Candle',
      prompt:
          'A green (bullish) candlestick means the closing price was higher than the opening price.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'A green or white candlestick is bullish — it means buyers pushed the price up from the open to the close during that period.',
      sagePrompt:
          'Explain bullish vs bearish candlesticks and what they indicate about market sentiment.',
    ),
    StockQuestion(
      id: 'w2l0q3',
      type: QuestionType.multipleChoice,
      concept: 'Doji',
      prompt:
          'A Doji candlestick (where open and close are nearly equal) signals:',
      options: [
        'A strong uptrend continuation',
        'Indecision between buyers and sellers',
        'A guaranteed price reversal',
        'Very high trading volume'
      ],
      correctIndex: 1,
      briefExplanation:
          'A Doji forms when open and close are nearly the same. It signals market indecision and potential trend reversal, especially after a strong move.',
      sagePrompt:
          'Explain Doji candlesticks and what they tell you about market indecision.',
    ),
    StockQuestion(
      id: 'w2l0q4',
      type: QuestionType.multipleChoice,
      concept: 'Hammer',
      prompt:
          'A Hammer candlestick has a small body at the top and a long lower wick. It typically signals:',
      options: [
        'Continued selling pressure',
        'A potential bullish reversal after a downtrend',
        'A breakdown to new lows',
        'Neutral market conditions'
      ],
      correctIndex: 1,
      briefExplanation:
          'A Hammer at the bottom of a downtrend suggests sellers pushed prices down but buyers stepped in and pushed the price back up by the close — a potential reversal signal.',
      sagePrompt:
          'Explain hammer candlesticks and their significance at support levels.',
    ),
    StockQuestion(
      id: 'w2l0q5',
      type: QuestionType.multipleChoice,
      concept: 'Shooting Star',
      prompt:
          'A Shooting Star has a small body at the bottom with a long upper wick. It appears after an uptrend and signals:',
      options: [
        'A bullish continuation',
        'A potential bearish reversal',
        'Increasing volume',
        'A gap up in tomorrow\'s open'
      ],
      correctIndex: 1,
      briefExplanation:
          'A Shooting Star shows buyers pushed prices up sharply during the session but sellers took control by the close. After an uptrend, this bearish signal suggests a potential top.',
      sagePrompt:
          'Explain the Shooting Star pattern and how to confirm it with other indicators.',
    ),
    StockQuestion(
      id: 'w2l0q6',
      type: QuestionType.trueFalse,
      concept: 'Engulfing Pattern',
      prompt:
          'A bullish engulfing pattern occurs when a large green candle fully covers the previous red candle\'s body.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'A bullish engulfing pattern at the end of a downtrend is a strong reversal signal. The large green candle "engulfs" the prior red candle, showing buyers overwhelmed sellers.',
      sagePrompt:
          'Explain engulfing patterns and why they are considered strong reversal signals.',
    ),
    StockQuestion(
      id: 'w2l0q7',
      type: QuestionType.multipleChoice,
      concept: 'Timeframes',
      prompt: 'A daily candlestick chart shows:',
      options: [
        'One candle per minute of trading',
        'One candle per trading hour',
        'One candle per trading day',
        'One candle per trading week'
      ],
      correctIndex: 2,
      briefExplanation:
          'On a daily chart, each candlestick represents one full trading day\'s open, high, low, and close. Traders use different timeframes (1-minute to monthly) depending on their strategy.',
      sagePrompt:
          'Explain chart timeframes and how different traders use them.',
    ),
    StockQuestion(
      id: 'w2l0q8',
      type: QuestionType.multipleChoice,
      concept: 'Morning Star',
      prompt:
          'A Morning Star is a three-candle bullish reversal pattern. Its middle candle is characterized by:',
      options: [
        'A large bullish body',
        'A small body showing indecision (Doji or small candle)',
        'A very long upper wick',
        'A gap down from the previous close'
      ],
      correctIndex: 1,
      briefExplanation:
          'The Morning Star has: (1) large bearish candle, (2) small indecisive candle (the "star"), (3) large bullish candle. It signals a bottom reversal after a downtrend.',
      sagePrompt:
          'Explain the Morning Star pattern and how to identify bottoms using candlesticks.',
    ),
    StockQuestion(
      id: 'w2l0q9',
      type: QuestionType.trueFalse,
      concept: 'Candlestick Confirmation',
      prompt:
          'A single candlestick pattern alone is sufficient to make a trading decision without any other context.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Candlestick patterns should be confirmed with volume, trend context, support/resistance levels, and other indicators. No single candle guarantees a price direction.',
      sagePrompt:
          'Explain the importance of confirmation when using candlestick patterns.',
    ),
  ];

  // ── W2 L1 — Volume & Momentum ─────────────────────────────────────────────
  static final List<StockQuestion> _w2l1Questions = [
    StockQuestion(
      id: 'w2l1q0',
      type: QuestionType.multipleChoice,
      concept: 'Volume',
      prompt: 'Rising stock price on increasing volume typically signals:',
      options: [
        'A weak, unsustainable move',
        'A strong move with conviction behind it',
        'An imminent reversal',
        'Institutional selling'
      ],
      correctIndex: 1,
      briefExplanation:
          'Price rising on strong volume shows broad participation and conviction. Volume confirms price moves — a rally on low volume is considered less trustworthy.',
      sagePrompt:
          'Explain the relationship between price and volume and how to use volume to confirm trends.',
    ),
    StockQuestion(
      id: 'w2l1q1',
      type: QuestionType.trueFalse,
      concept: 'Volume Divergence',
      prompt:
          'A stock making new highs while volume is declining is a bullish signal.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Price making new highs on declining volume is a bearish divergence — the move lacks conviction. It suggests the uptrend may be losing strength.',
      sagePrompt:
          'Explain volume divergence and what it means when price and volume move in opposite directions.',
    ),
    StockQuestion(
      id: 'w2l1q2',
      type: QuestionType.multipleChoice,
      concept: 'RSI',
      prompt: 'An RSI reading above 70 typically indicates a stock is:',
      options: [
        'Oversold and likely to rise',
        'Overbought and potentially due for a pullback',
        'In a strong uptrend with no risk',
        'About to report earnings'
      ],
      correctIndex: 1,
      briefExplanation:
          'RSI above 70 indicates overbought conditions — the stock has risen quickly and may be due for a pullback. RSI below 30 indicates oversold conditions.',
      sagePrompt:
          'Explain the RSI indicator and how to use it to identify overbought and oversold conditions.',
    ),
    StockQuestion(
      id: 'w2l1q3',
      type: QuestionType.multipleChoice,
      concept: 'MACD',
      prompt: 'A MACD bullish crossover occurs when:',
      options: [
        'The MACD line crosses above the signal line',
        'The MACD line crosses below the signal line',
        'The MACD histogram reaches zero',
        'RSI and MACD reach the same value'
      ],
      correctIndex: 0,
      briefExplanation:
          'A bullish MACD crossover happens when the MACD line crosses above the signal line. This suggests upward momentum is building and is often used as a buy signal.',
      sagePrompt:
          'Explain the MACD indicator and how crossovers are used as trading signals.',
    ),
    StockQuestion(
      id: 'w2l1q4',
      type: QuestionType.multipleChoice,
      concept: 'Momentum',
      prompt: 'Momentum investing is based on the principle that:',
      options: [
        'Cheap stocks always outperform expensive ones',
        'Stocks that have risen recently tend to continue rising',
        'Dividend-paying stocks beat non-dividend payers',
        'Small companies grow faster than large ones'
      ],
      correctIndex: 1,
      briefExplanation:
          'Momentum investing follows the trend — stocks that have outperformed recently tend to continue outperforming in the near term. Research shows momentum is one of the most persistent market anomalies.',
      sagePrompt:
          'Explain momentum investing and the academic evidence supporting it.',
    ),
    StockQuestion(
      id: 'w2l1q5',
      type: QuestionType.trueFalse,
      concept: 'On-Balance Volume',
      prompt:
          'On-Balance Volume (OBV) adds volume on up days and subtracts it on down days to track money flow.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'OBV is a cumulative indicator. When price closes up, the full day\'s volume is added; when price closes down, it is subtracted. OBV rising ahead of price can signal upcoming strength.',
      sagePrompt:
          'Explain On-Balance Volume and how it can be used to spot institutional accumulation.',
    ),
    StockQuestion(
      id: 'w2l1q6',
      type: QuestionType.multipleChoice,
      concept: 'Average Volume',
      prompt:
          'A stock trading at 3x its average volume after an earnings announcement likely means:',
      options: [
        'The company made an error in its filing',
        'There is unusually high investor interest and activity',
        'The stock is about to be delisted',
        'The market is about to close early'
      ],
      correctIndex: 1,
      briefExplanation:
          'Volume spikes around earnings indicate high investor reaction — either excitement or panic. Unusual volume often accompanies significant price moves.',
      sagePrompt:
          'Explain volume spikes around catalysts like earnings and what they mean for traders.',
    ),
    StockQuestion(
      id: 'w2l1q7',
      type: QuestionType.multipleChoice,
      concept: 'Stochastic Oscillator',
      prompt: 'The Stochastic Oscillator compares a stock\'s closing price to:',
      options: [
        'Its opening price',
        'Its price range over a given period',
        'The S&P 500\'s performance',
        'Its 200-day moving average'
      ],
      correctIndex: 1,
      briefExplanation:
          'The Stochastic Oscillator measures where the current close is relative to the high-low range over N periods. Readings above 80 are overbought; below 20 are oversold.',
      sagePrompt:
          'Explain the Stochastic Oscillator and how it differs from RSI.',
    ),
    StockQuestion(
      id: 'w2l1q8',
      type: QuestionType.trueFalse,
      concept: 'Relative Strength',
      prompt:
          'Relative strength compares a stock\'s performance to a benchmark, not just its own past price.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Relative strength shows how a stock performs versus a benchmark (like the S&P 500). A stock rising 5% while the market rises 10% has negative relative strength despite its absolute gains.',
      sagePrompt:
          'Explain relative strength and how sector rotation uses it to find outperforming areas.',
    ),
    StockQuestion(
      id: 'w2l1q9',
      type: QuestionType.multipleChoice,
      concept: 'Bollinger Bands',
      prompt:
          'When a stock\'s price touches the upper Bollinger Band, it suggests:',
      options: [
        'The stock is guaranteed to fall',
        'The stock may be overbought relative to recent volatility',
        'The stock should be bought immediately',
        'The stock\'s volume is unusually high'
      ],
      correctIndex: 1,
      briefExplanation:
          'Bollinger Bands are set 2 standard deviations from a 20-day moving average. Price at the upper band may indicate overbought conditions, but in strong uptrends, price can "walk the band."',
      sagePrompt:
          'Explain Bollinger Bands and the concept of volatility expansion and contraction.',
    ),
  ];

  // ── W2 L2 — Support & Resistance ─────────────────────────────────────────
  static final List<StockQuestion> _w2l2Questions = [
    StockQuestion(
      id: 'w2l2q0',
      type: QuestionType.multipleChoice,
      concept: 'Support',
      prompt: 'A support level is a price at which:',
      options: [
        'Sellers historically overwhelm buyers causing price to fall',
        'Buying interest has historically been strong enough to stop price from falling',
        'The stock always reverses and makes new highs',
        'The company provides financial support to shareholders'
      ],
      correctIndex: 1,
      briefExplanation:
          'Support is a price floor where demand has historically exceeded supply. When price approaches support, buyers step in and the price tends to bounce.',
      sagePrompt:
          'Explain support levels and why prices tend to bounce at them.',
    ),
    StockQuestion(
      id: 'w2l2q1',
      type: QuestionType.multipleChoice,
      concept: 'Resistance',
      prompt: 'A resistance level is where:',
      options: [
        'Buyers historically overwhelm sellers causing price to rise',
        'Selling pressure has historically been strong enough to stop price from rising',
        'The stock dividend is reduced',
        'Trading is halted by regulators'
      ],
      correctIndex: 1,
      briefExplanation:
          'Resistance is a price ceiling where supply has historically exceeded demand. When price approaches resistance, sellers step in and the price tends to reverse downward.',
      sagePrompt:
          'Explain resistance levels and why prices tend to reverse at them.',
    ),
    StockQuestion(
      id: 'w2l2q2',
      type: QuestionType.trueFalse,
      concept: 'Role Reversal',
      prompt:
          'When a resistance level is broken, it often becomes a new support level.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'This is called "role reversal" or "polarity change." Once resistance is broken and buyers take control above that level, the old resistance becomes the new floor (support).',
      sagePrompt:
          'Explain support/resistance role reversal and give an example of how to trade it.',
    ),
    StockQuestion(
      id: 'w2l2q3',
      type: QuestionType.multipleChoice,
      concept: 'Round Numbers',
      prompt:
          'Why do round numbers like \$100, \$200, or \$500 often act as support or resistance?',
      options: [
        'They are required by SEC regulations',
        'Traders psychologically place orders at round numbers, creating clusters of activity',
        'Computers automatically halt trading at round numbers',
        'Companies set dividend dates at round number prices'
      ],
      correctIndex: 1,
      briefExplanation:
          'Round numbers attract large clusters of buy and sell orders due to human psychology. Institutional traders often set limit orders and stop-losses at round numbers.',
      sagePrompt:
          'Explain psychological price levels and how round numbers create support and resistance.',
    ),
    StockQuestion(
      id: 'w2l2q4',
      type: QuestionType.multipleChoice,
      concept: 'Breakout',
      prompt: 'A breakout occurs when price:',
      options: [
        'Retreats back to its moving average',
        'Moves decisively through a support or resistance level on strong volume',
        'Gaps down at market open',
        'Falls below its 52-week low'
      ],
      correctIndex: 1,
      briefExplanation:
          'A breakout is when price moves through a key level (support or resistance) with conviction, usually on above-average volume. It signals a potential new trend direction.',
      sagePrompt:
          'Explain breakouts and how to distinguish real breakouts from false ones.',
    ),
    StockQuestion(
      id: 'w2l2q5',
      type: QuestionType.trueFalse,
      concept: 'False Breakout',
      prompt:
          'A false breakout (or "fakeout") can trap traders who bought on the initial move.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'False breakouts occur when price briefly moves through a level but then reverses. They trap breakout buyers and are often followed by sharp moves in the opposite direction.',
      sagePrompt:
          'Explain false breakouts and strategies to avoid being trapped by them.',
    ),
    StockQuestion(
      id: 'w2l2q6',
      type: QuestionType.multipleChoice,
      concept: 'Fibonacci Retracement',
      prompt:
          'Fibonacci retracement levels (23.6%, 38.2%, 61.8%) are used to identify:',
      options: [
        'Guaranteed price targets',
        'Potential support levels after a price decline from a high',
        'Company earnings growth rates',
        'The number of shares traded each day'
      ],
      correctIndex: 1,
      briefExplanation:
          'Fibonacci retracement levels are potential support areas where a pullback might end during an uptrend. The 61.8% level (the "golden ratio") is considered especially significant.',
      sagePrompt:
          'Explain Fibonacci retracement and why so many traders watch these levels.',
    ),
    StockQuestion(
      id: 'w2l2q7',
      type: QuestionType.multipleChoice,
      concept: 'Trendline',
      prompt: 'An uptrend line is drawn by connecting:',
      options: [
        'The highest points on a chart',
        'The lowest points (higher lows) on a chart',
        'Opening prices over time',
        'Average prices over a period'
      ],
      correctIndex: 1,
      briefExplanation:
          'An uptrend line connects the series of higher lows. As long as price stays above this line, the uptrend is intact. A break below the trendline is a warning signal.',
      sagePrompt:
          'Explain how to draw trendlines and what a trendline break means.',
    ),
    StockQuestion(
      id: 'w2l2q8',
      type: QuestionType.trueFalse,
      concept: 'Price Consolidation',
      prompt:
          'A price consolidation zone (sideways movement) often acts as both support and resistance for future moves.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Consolidation zones represent areas of equilibrium where the market spent time. These levels are "remembered" and often provide support on pullbacks or resistance on rallies.',
      sagePrompt:
          'Explain price consolidation and why these zones matter as future reference points.',
    ),
    StockQuestion(
      id: 'w2l2q9',
      type: QuestionType.multipleChoice,
      concept: 'Volume at Support',
      prompt:
          'When a stock holds support on high volume, it generally indicates:',
      options: [
        'The support level is about to break',
        'Strong buying conviction at that level',
        'The stock is manipulated',
        'A dividend is about to be paid'
      ],
      correctIndex: 1,
      briefExplanation:
          'High volume at a support level confirms that buyers are aggressively defending the price. This adds credibility to the support and suggests the level may hold.',
      sagePrompt:
          'Explain how to use volume to confirm support and resistance levels.',
    ),
  ];

  // ── W2 L3 — Moving Averages ───────────────────────────────────────────────
  static final List<StockQuestion> _w2l3Questions = [
    StockQuestion(
      id: 'w2l3q0',
      type: QuestionType.multipleChoice,
      concept: 'SMA',
      prompt: 'A 50-day Simple Moving Average (SMA) is calculated by:',
      options: [
        'Taking the median price of the last 50 days',
        'Averaging the closing prices of the last 50 trading days',
        'Adding the high and low of 50 days and dividing by 2',
        'Weighting recent days more heavily than older days'
      ],
      correctIndex: 1,
      briefExplanation:
          'The 50-day SMA is the average of the last 50 daily closing prices, updated each day as the oldest price is dropped and the newest is added.',
      sagePrompt:
          'Explain simple moving averages and how they smooth price data to reveal trends.',
    ),
    StockQuestion(
      id: 'w2l3q1',
      type: QuestionType.multipleChoice,
      concept: 'EMA',
      prompt:
          'Compared to a Simple Moving Average, an Exponential Moving Average (EMA):',
      options: [
        'Reacts more slowly to recent price changes',
        'Reacts more quickly to recent price changes',
        'Uses the same calculation method',
        'Only works on weekly charts'
      ],
      correctIndex: 1,
      briefExplanation:
          'EMA gives more weight to recent prices, making it more responsive to new information than the SMA. Traders use shorter EMAs (like 9 or 12-day) for faster signals.',
      sagePrompt:
          'Explain the difference between SMA and EMA and when to use each.',
    ),
    StockQuestion(
      id: 'w2l3q2',
      type: QuestionType.trueFalse,
      concept: 'Golden Cross',
      prompt:
          'A Golden Cross occurs when the 50-day moving average crosses above the 200-day moving average.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'The Golden Cross is a widely followed bullish signal where the shorter-term 50-day MA crosses above the longer-term 200-day MA, suggesting a shift to an uptrend.',
      sagePrompt:
          'Explain the Golden Cross and Death Cross signals and their historical track record.',
    ),
    StockQuestion(
      id: 'w2l3q3',
      type: QuestionType.multipleChoice,
      concept: 'Death Cross',
      prompt: 'A Death Cross is when:',
      options: [
        'A stock\'s price falls 50% from its high',
        'The 50-day MA crosses below the 200-day MA',
        'Trading volume drops to zero',
        'A company files for bankruptcy'
      ],
      correctIndex: 1,
      briefExplanation:
          'A Death Cross is the bearish opposite of a Golden Cross — the 50-day MA crosses below the 200-day MA, suggesting potential for continued weakness.',
      sagePrompt:
          'Explain the Death Cross and historical market performance following this signal.',
    ),
    StockQuestion(
      id: 'w2l3q4',
      type: QuestionType.multipleChoice,
      concept: 'MA as Support',
      prompt:
          'During a strong uptrend, the 50-day moving average often acts as:',
      options: [
        'A resistance level where traders sell',
        'A dynamic support level where buyers step in',
        'A target price for analysts',
        'An irrelevant technical level'
      ],
      correctIndex: 1,
      briefExplanation:
          'In a healthy uptrend, price often pulls back to the 50-day or 200-day MA before resuming higher. Many traders use these levels as buying opportunities.',
      sagePrompt:
          'Explain how moving averages act as dynamic support and resistance in trending markets.',
    ),
    StockQuestion(
      id: 'w2l3q5',
      type: QuestionType.trueFalse,
      concept: 'Lagging Indicator',
      prompt:
          'Moving averages are leading indicators that predict future price movements.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Moving averages are lagging indicators — they are based on past prices. They confirm trends after they have started rather than predicting them in advance.',
      sagePrompt:
          'Explain the difference between leading and lagging indicators in technical analysis.',
    ),
    StockQuestion(
      id: 'w2l3q6',
      type: QuestionType.multipleChoice,
      concept: 'MA Ribbon',
      prompt:
          'A Moving Average Ribbon shows multiple MAs of different periods. When shorter MAs are stacked above longer ones, it suggests:',
      options: [
        'A strong downtrend',
        'A strong uptrend',
        'Market consolidation',
        'High dividend payments'
      ],
      correctIndex: 1,
      briefExplanation:
          'When shorter-period MAs (e.g. 10, 20, 50-day) are all above longer ones (100, 200-day) in order, it shows a well-established uptrend with momentum.',
      sagePrompt:
          'Explain Moving Average Ribbons and how to read them for trend strength.',
    ),
    StockQuestion(
      id: 'w2l3q7',
      type: QuestionType.multipleChoice,
      concept: 'Whipsaw',
      prompt: 'A "whipsaw" in moving average trading refers to:',
      options: [
        'A large single-day price move',
        'Multiple false signals generated by choppy, sideways price action',
        'A stock that moves opposite to the market',
        'A broker charging excessive fees'
      ],
      correctIndex: 1,
      briefExplanation:
          'Whipsaws occur when price crosses back and forth over a moving average in sideways markets, generating multiple false buy and sell signals. MAs work best in trending markets.',
      sagePrompt:
          'Explain whipsaws and why moving averages work poorly in ranging markets.',
    ),
    StockQuestion(
      id: 'w2l3q8',
      type: QuestionType.trueFalse,
      concept: 'VWAP',
      prompt:
          'VWAP (Volume Weighted Average Price) gives equal weight to every trade regardless of size.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'VWAP weights each trade by its volume, giving more influence to large trades. It is used by institutional traders as a benchmark for execution quality.',
      sagePrompt:
          'Explain VWAP and how institutional traders use it for order execution.',
    ),
    StockQuestion(
      id: 'w2l3q9',
      type: QuestionType.multipleChoice,
      concept: 'MA Period Selection',
      prompt:
          'A day trader would most likely use which moving average combination?',
      options: [
        '50-day and 200-day MAs',
        '9-period and 21-period EMAs',
        '12-month and 24-month MAs',
        '100-day and 300-day MAs'
      ],
      correctIndex: 1,
      briefExplanation:
          'Day traders use short-period EMAs (9, 12, 21-period) on intraday charts to capture fast-moving signals. The 200-day MA is irrelevant on a 5-minute chart.',
      sagePrompt:
          'Explain how traders select moving average periods based on their trading timeframe.',
    ),
  ];

  // ── W2 L4 — Chart Patterns ────────────────────────────────────────────────
  static final List<StockQuestion> _w2l4Questions = [
    StockQuestion(
      id: 'w2l4q0',
      type: QuestionType.multipleChoice,
      concept: 'Head and Shoulders',
      prompt: 'A Head and Shoulders top pattern signals:',
      options: [
        'A bullish continuation of the uptrend',
        'A bearish reversal from an uptrend to a downtrend',
        'A sideways consolidation period',
        'An imminent stock split'
      ],
      correctIndex: 1,
      briefExplanation:
          'The Head and Shoulders top is one of the most reliable reversal patterns. Three peaks (left shoulder, head, right shoulder) with a neckline breakout signal the end of an uptrend.',
      sagePrompt:
          'Explain the Head and Shoulders pattern and how to calculate its price target.',
    ),
    StockQuestion(
      id: 'w2l4q1',
      type: QuestionType.multipleChoice,
      concept: 'Inverse Head and Shoulders',
      prompt: 'An Inverse Head and Shoulders pattern typically occurs:',
      options: [
        'At market tops before a major decline',
        'At market bottoms before a potential rally',
        'During periods of high volatility',
        'Only in bear markets'
      ],
      correctIndex: 1,
      briefExplanation:
          'The Inverse Head and Shoulders is a bullish reversal pattern that forms at the end of a downtrend. A breakout above the neckline signals a potential new uptrend.',
      sagePrompt:
          'Explain the Inverse Head and Shoulders and how it differs from the regular pattern.',
    ),
    StockQuestion(
      id: 'w2l4q2',
      type: QuestionType.trueFalse,
      concept: 'Double Top',
      prompt:
          'A Double Top pattern is confirmed when price breaks below the support level between the two peaks.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'A Double Top is confirmed when price breaks below the "neckline" (the low between the two peaks). Only then is the bearish reversal signal complete.',
      sagePrompt:
          'Explain Double Top and Double Bottom patterns and how to trade them.',
    ),
    StockQuestion(
      id: 'w2l4q3',
      type: QuestionType.multipleChoice,
      concept: 'Ascending Triangle',
      prompt:
          'An Ascending Triangle has a flat top resistance and rising lows. It typically resolves:',
      options: [
        'With a breakdown below the rising lows',
        'With a breakout above the flat resistance (bullish)',
        'With a move to the exact midpoint of the pattern',
        'With a gap down on earnings'
      ],
      correctIndex: 1,
      briefExplanation:
          'Ascending Triangles are bullish continuation patterns. Rising lows show buyers getting more aggressive, and the flat top eventually breaks as selling pressure is exhausted.',
      sagePrompt:
          'Explain ascending and descending triangle patterns and their typical resolutions.',
    ),
    StockQuestion(
      id: 'w2l4q4',
      type: QuestionType.multipleChoice,
      concept: 'Flag Pattern',
      prompt: 'A Bull Flag pattern consists of:',
      options: [
        'A long downtrend followed by a brief upward pause',
        'A sharp price rally (the flagpole) followed by a brief consolidation (the flag)',
        'Two equal highs with declining volume',
        'A broadening price range over several weeks'
      ],
      correctIndex: 1,
      briefExplanation:
          'A Bull Flag is a continuation pattern: a sharp rally creates the "pole," then price consolidates in a tight, slightly downward channel (the "flag") before breaking higher.',
      sagePrompt:
          'Explain flag and pennant patterns and how to calculate price targets from them.',
    ),
    StockQuestion(
      id: 'w2l4q5',
      type: QuestionType.trueFalse,
      concept: 'Cup and Handle',
      prompt:
          'The Cup and Handle pattern is a bearish reversal pattern that signals the end of an uptrend.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'The Cup and Handle is a bullish continuation pattern. It shows a rounded base (cup) followed by a brief pullback (handle) before breaking to new highs.',
      sagePrompt:
          'Explain the Cup and Handle pattern and William O\'Neil\'s use of it in growth investing.',
    ),
    StockQuestion(
      id: 'w2l4q6',
      type: QuestionType.multipleChoice,
      concept: 'Symmetrical Triangle',
      prompt: 'A Symmetrical Triangle (converging trendlines) is considered:',
      options: [
        'Always bullish',
        'Always bearish',
        'A neutral consolidation pattern that can break in either direction',
        'A signal of an upcoming dividend cut'
      ],
      correctIndex: 2,
      briefExplanation:
          'A Symmetrical Triangle is neutral — it shows decreasing volatility as buyers and sellers reach equilibrium. The breakout direction determines whether it resolves bullish or bearish.',
      sagePrompt:
          'Explain symmetrical triangles and how to prepare for breakouts in either direction.',
    ),
    StockQuestion(
      id: 'w2l4q7',
      type: QuestionType.multipleChoice,
      concept: 'Wedge Pattern',
      prompt:
          'A Rising Wedge (both trendlines sloping up but converging) is typically:',
      options: [
        'A bullish continuation signal',
        'A bearish reversal signal',
        'A neutral consolidation',
        'A signal to buy more shares'
      ],
      correctIndex: 1,
      briefExplanation:
          'Despite sloping upward, a Rising Wedge is bearish. Price is making higher highs and higher lows but the advances are getting smaller — suggesting weakening momentum before a reversal.',
      sagePrompt:
          'Explain Rising and Falling Wedge patterns and why they often lead to sharp reversals.',
    ),
    StockQuestion(
      id: 'w2l4q8',
      type: QuestionType.trueFalse,
      concept: 'Pattern Failure',
      prompt:
          'Chart patterns fail sometimes and do not always resolve as expected.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'No chart pattern is 100% reliable. Patterns fail regularly, which is why proper risk management (stop-losses) is essential. Patterns show probability, not certainty.',
      sagePrompt:
          'Explain pattern failure and how to manage risk when trading chart patterns.',
    ),
    StockQuestion(
      id: 'w2l4q9',
      type: QuestionType.multipleChoice,
      concept: 'Price Target',
      prompt:
          'After a Head and Shoulders breakout, the price target is typically estimated by:',
      options: [
        'Adding the previous uptrend\'s length to the neckline',
        'Subtracting the head-to-neckline distance from the neckline breakout point',
        'Multiplying the right shoulder height by 2',
        'Using the 200-day moving average as the target'
      ],
      correctIndex: 1,
      briefExplanation:
          'The H&S price target is the neckline minus the distance from the head to the neckline. This measured move gives a conservative downside target after the neckline breaks.',
      sagePrompt:
          'Explain how to calculate price targets from chart patterns using measured moves.',
    ),
  ];

  // ════════════════════════════════════════════════════════════════════════════
  // WORLD 3 QUESTIONS
  // ════════════════════════════════════════════════════════════════════════════

  // ── W3 L0 — Reading Earnings ──────────────────────────────────────────────
  static final List<StockQuestion> _w3l0Questions = [
    StockQuestion(
      id: 'w3l0q0',
      type: QuestionType.multipleChoice,
      concept: 'EPS',
      prompt: 'Earnings Per Share (EPS) is calculated as:',
      options: [
        'Revenue divided by shares outstanding',
        'Net income divided by shares outstanding',
        'Gross profit divided by share price',
        'Operating income divided by revenue'
      ],
      correctIndex: 1,
      briefExplanation:
          'EPS = Net Income ÷ Shares Outstanding. It shows how much profit a company generates per share, making it easier to compare companies of different sizes.',
      sagePrompt:
          'Explain EPS and why it is one of the most watched metrics during earnings season.',
    ),
    StockQuestion(
      id: 'w3l0q1',
      type: QuestionType.trueFalse,
      concept: 'Earnings Beat',
      prompt:
          'A company can have its stock fall even after reporting better-than-expected earnings.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          '"Buy the rumor, sell the news" is a real phenomenon. If expectations were very high, even a beat can disappoint. Additionally, weak forward guidance can cause a sell-off despite a good quarter.',
      sagePrompt:
          'Explain earnings reactions and why stocks sometimes fall on good earnings reports.',
    ),
    StockQuestion(
      id: 'w3l0q2',
      type: QuestionType.multipleChoice,
      concept: 'Revenue vs Earnings',
      prompt: 'What is the difference between revenue and earnings?',
      options: [
        'They are the same thing',
        'Revenue is total sales; earnings (net income) is what remains after all expenses',
        'Earnings includes taxes while revenue does not',
        'Revenue is for services; earnings is for products'
      ],
      correctIndex: 1,
      briefExplanation:
          'Revenue (top line) is total sales before any deductions. Earnings (bottom line/net income) is what is left after subtracting costs, expenses, taxes, and interest.',
      sagePrompt:
          'Explain the income statement and the journey from revenue to net income.',
    ),
    StockQuestion(
      id: 'w3l0q3',
      type: QuestionType.multipleChoice,
      concept: 'Guidance',
      prompt: 'When a company "raises guidance," it means:',
      options: [
        'It is increasing executive salaries',
        'It is increasing its forecast for future revenue or earnings',
        'It is adding more analysts to its investor relations team',
        'It is revising last quarter\'s results upward'
      ],
      correctIndex: 1,
      briefExplanation:
          'Guidance is management\'s forward-looking estimate for future performance. Raising guidance is bullish — it tells investors the business is doing better than previously expected.',
      sagePrompt:
          'Explain earnings guidance and why forward guidance often matters more than past results.',
    ),
    StockQuestion(
      id: 'w3l0q4',
      type: QuestionType.multipleChoice,
      concept: 'Gross Margin',
      prompt: 'Gross margin is calculated as:',
      options: [
        '(Revenue - Operating Expenses) / Revenue',
        '(Revenue - Cost of Goods Sold) / Revenue',
        'Net Income / Revenue',
        'Operating Income / Total Assets'
      ],
      correctIndex: 1,
      briefExplanation:
          'Gross Margin = (Revenue - COGS) / Revenue. It shows how much profit remains after direct production costs. Higher gross margins indicate pricing power and efficiency.',
      sagePrompt:
          'Explain gross margin and how it differs from operating margin and net margin.',
    ),
    StockQuestion(
      id: 'w3l0q5',
      type: QuestionType.trueFalse,
      concept: 'Whisper Number',
      prompt:
          'The "whisper number" refers to the unofficial earnings expectation that is often higher than official analyst consensus.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Whisper numbers are informal expectations circulated among traders. Stocks are often judged against the whisper number, not the official consensus, which is why some beats still result in declines.',
      sagePrompt:
          'Explain whisper numbers and the role of expectations in earnings reactions.',
    ),
    StockQuestion(
      id: 'w3l0q6',
      type: QuestionType.multipleChoice,
      concept: 'EBITDA',
      prompt:
          'EBITDA stands for Earnings Before Interest, Taxes, Depreciation, and Amortization. It is used to:',
      options: [
        'Calculate a company\'s tax liability',
        'Assess operating profitability while removing non-cash and financing effects',
        'Determine dividend payment amounts',
        'Measure the market value of a company'
      ],
      correctIndex: 1,
      briefExplanation:
          'EBITDA strips out non-cash charges (D&A) and financing costs (interest, taxes) to give a cleaner view of operational performance. It is widely used in valuation multiples.',
      sagePrompt:
          'Explain EBITDA and its use in company valuation and leveraged buyout analysis.',
    ),
    StockQuestion(
      id: 'w3l0q7',
      type: QuestionType.multipleChoice,
      concept: 'Earnings Season',
      prompt: 'US earnings season primarily occurs:',
      options: [
        'Once per year in December',
        'Four times per year, roughly in January, April, July, and October',
        'Every month for large companies',
        'Only when companies choose to report'
      ],
      correctIndex: 1,
      briefExplanation:
          'US public companies report quarterly earnings, creating four earnings seasons each year. The busiest weeks are when Dow and S&P 500 companies report in quick succession.',
      sagePrompt:
          'Explain earnings season and how to prepare for earnings announcements as an investor.',
    ),
    StockQuestion(
      id: 'w3l0q8',
      type: QuestionType.trueFalse,
      concept: 'Adjusted EPS',
      prompt: 'Adjusted EPS and GAAP EPS always show the same number.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Adjusted EPS excludes "one-time" items like restructuring charges, stock-based compensation, or acquisition costs. Companies often report adjusted EPS to show underlying business performance, which is typically higher than GAAP EPS.',
      sagePrompt:
          'Explain GAAP vs non-GAAP earnings and the controversy around companies using adjusted metrics.',
    ),
    StockQuestion(
      id: 'w3l0q9',
      type: QuestionType.multipleChoice,
      concept: 'Operating Leverage',
      prompt: 'A company with high operating leverage means:',
      options: [
        'It has a lot of debt on its balance sheet',
        'A small change in revenue causes a large change in operating profit',
        'It operates many different business divisions',
        'It uses a lot of physical equipment'
      ],
      correctIndex: 1,
      briefExplanation:
          'High operating leverage means most costs are fixed. When revenue grows, profits grow faster (positive leverage). But when revenue falls, losses also accelerate.',
      sagePrompt:
          'Explain operating leverage and how to identify high vs low operating leverage businesses.',
    ),
  ];

  // ── W3 L1 — Valuation Ratios ──────────────────────────────────────────────
  static final List<StockQuestion> _w3l1Questions = [
    StockQuestion(
      id: 'w3l1q0',
      type: QuestionType.multipleChoice,
      concept: 'P/E Ratio',
      prompt: 'The Price-to-Earnings (P/E) ratio measures:',
      options: [
        'How much a company earns relative to its debt',
        'How much investors pay per dollar of a company\'s earnings',
        'The percentage of earnings paid as dividends',
        'The growth rate of a company\'s earnings'
      ],
      correctIndex: 1,
      briefExplanation:
          'P/E = Share Price ÷ EPS. A P/E of 20 means investors pay \$20 for each \$1 of annual earnings. Higher P/E suggests higher growth expectations.',
      sagePrompt:
          'Explain the P/E ratio and how to use it to compare valuations across companies and sectors.',
    ),
    StockQuestion(
      id: 'w3l1q1',
      type: QuestionType.trueFalse,
      concept: 'Forward P/E',
      prompt:
          'Forward P/E uses future estimated earnings, making it more forward-looking than trailing P/E.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Forward P/E divides the current price by next year\'s estimated earnings. Since stocks are priced on future expectations, forward P/E is often more relevant than backward-looking trailing P/E.',
      sagePrompt:
          'Explain trailing vs forward P/E and the limitations of using earnings estimates.',
    ),
    StockQuestion(
      id: 'w3l1q2',
      type: QuestionType.multipleChoice,
      concept: 'PEG Ratio',
      prompt: 'The PEG ratio improves on the P/E ratio by:',
      options: [
        'Accounting for dividend yield',
        'Dividing the P/E by the earnings growth rate',
        'Using revenue instead of earnings',
        'Adjusting for inflation'
      ],
      correctIndex: 1,
      briefExplanation:
          'PEG = P/E ÷ Earnings Growth Rate. A PEG below 1 may indicate undervaluation relative to growth. It helps compare growth companies that have high P/Es but fast earnings growth.',
      sagePrompt:
          'Explain the PEG ratio and Peter Lynch\'s use of it to find growth stocks at reasonable prices.',
    ),
    StockQuestion(
      id: 'w3l1q3',
      type: QuestionType.multipleChoice,
      concept: 'P/B Ratio',
      prompt:
          'The Price-to-Book (P/B) ratio compares a company\'s market value to its:',
      options: [
        'Annual revenue',
        'Book value (assets minus liabilities)',
        'Dividend payments',
        'Cash holdings'
      ],
      correctIndex: 1,
      briefExplanation:
          'P/B = Market Price ÷ Book Value Per Share. Book value is total assets minus total liabilities. A P/B below 1 could mean a stock is undervalued or the business is struggling.',
      sagePrompt:
          'Explain the P/B ratio and when it is most useful (financial stocks, asset-heavy companies).',
    ),
    StockQuestion(
      id: 'w3l1q4',
      type: QuestionType.multipleChoice,
      concept: 'EV/EBITDA',
      prompt: 'Enterprise Value (EV) differs from market cap because it:',
      options: [
        'Only counts institutional shareholders',
        'Includes debt and subtracts cash, giving a true acquisition cost',
        'Uses future earnings instead of current ones',
        'Adjusts for inflation'
      ],
      correctIndex: 1,
      briefExplanation:
          'EV = Market Cap + Debt - Cash. It represents what it would actually cost to buy the entire business. EV/EBITDA is preferred for comparing companies with different capital structures.',
      sagePrompt:
          'Explain Enterprise Value and why EV/EBITDA is preferred over P/E for certain valuations.',
    ),
    StockQuestion(
      id: 'w3l1q5',
      type: QuestionType.trueFalse,
      concept: 'P/S Ratio',
      prompt:
          'The Price-to-Sales (P/S) ratio is particularly useful for companies with negative earnings.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'P/S = Market Cap ÷ Annual Revenue. For early-stage or high-growth companies with no earnings, P/S provides a valuation metric when P/E is meaningless.',
      sagePrompt:
          'Explain the P/S ratio and when to use it vs other valuation multiples.',
    ),
    StockQuestion(
      id: 'w3l1q6',
      type: QuestionType.multipleChoice,
      concept: 'Value vs Growth',
      prompt: 'A "value stock" typically has:',
      options: [
        'High P/E and high revenue growth',
        'Low P/E, low P/B, and often pays dividends',
        'Negative earnings but fast user growth',
        'A price below \$10 per share'
      ],
      correctIndex: 1,
      briefExplanation:
          'Value stocks trade at low multiples relative to earnings, book value, or cash flow. They are often mature businesses in slower-growing industries, frequently paying dividends.',
      sagePrompt:
          'Explain the difference between value and growth investing and the historical performance of each style.',
    ),
    StockQuestion(
      id: 'w3l1q7',
      type: QuestionType.multipleChoice,
      concept: 'DCF',
      prompt:
          'A Discounted Cash Flow (DCF) valuation determines a stock\'s intrinsic value by:',
      options: [
        'Comparing its P/E to industry peers',
        'Discounting projected future cash flows back to their present value',
        'Multiplying current earnings by the historical P/E',
        'Adding book value to expected dividend payments'
      ],
      correctIndex: 1,
      briefExplanation:
          'DCF calculates today\'s value of all future cash flows using a discount rate (reflecting risk and opportunity cost). It is theoretically the most rigorous valuation method but very sensitive to assumptions.',
      sagePrompt:
          'Explain DCF valuation and why small changes in assumptions cause large changes in the output.',
    ),
    StockQuestion(
      id: 'w3l1q8',
      type: QuestionType.trueFalse,
      concept: 'CAPE Ratio',
      prompt:
          'The CAPE ratio (Cyclically Adjusted P/E) uses 10-year average earnings to smooth out business cycle effects.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Developed by Robert Shiller, CAPE divides price by the 10-year inflation-adjusted average earnings. It is used to gauge long-term market valuation and has historically predicted 10-year returns.',
      sagePrompt:
          'Explain the CAPE ratio and its use as a long-term market valuation gauge.',
    ),
    StockQuestion(
      id: 'w3l1q9',
      type: QuestionType.multipleChoice,
      concept: 'Valuation Context',
      prompt:
          'A technology company with a P/E of 35 and a utility company with a P/E of 35 are:',
      options: [
        'Both equally valued since they have the same P/E',
        'Not comparable — P/E should be assessed within industry context',
        'Both overvalued since 35 is always high',
        'Both undervalued since 35 is always low'
      ],
      correctIndex: 1,
      briefExplanation:
          'P/E ratios vary significantly by industry. Tech companies command higher multiples due to faster growth expectations. Utilities trade at lower multiples. Always compare within sectors.',
      sagePrompt:
          'Explain why valuation multiples must be compared within industry context, not in absolute terms.',
    ),
  ];

  // ── W3 L2 — Balance Sheet ─────────────────────────────────────────────────
  static final List<StockQuestion> _w3l2Questions = [
    StockQuestion(
      id: 'w3l2q0',
      type: QuestionType.multipleChoice,
      concept: 'Balance Sheet Equation',
      prompt: 'The fundamental balance sheet equation is:',
      options: [
        'Revenue = Expenses + Profit',
        'Assets = Liabilities + Shareholders\' Equity',
        'Cash Flow = Net Income + Depreciation',
        'Market Cap = Book Value + Goodwill'
      ],
      correctIndex: 1,
      briefExplanation:
          'The balance sheet must always balance: Assets = Liabilities + Equity. Assets are funded either by borrowing (liabilities) or by investor capital/retained earnings (equity).',
      sagePrompt:
          'Explain the balance sheet equation and what each component tells you about a company.',
    ),
    StockQuestion(
      id: 'w3l2q1',
      type: QuestionType.multipleChoice,
      concept: 'Current Assets',
      prompt: 'Current assets are best defined as:',
      options: [
        'Assets owned for more than 10 years',
        'Assets expected to be converted to cash within one year',
        'The company\'s most valuable long-term investments',
        'Equipment and property owned by the company'
      ],
      correctIndex: 1,
      briefExplanation:
          'Current assets include cash, receivables, and inventory — items that will be used or converted to cash within 12 months. They are key to assessing short-term financial health.',
      sagePrompt:
          'Explain current vs non-current assets and why the distinction matters for liquidity analysis.',
    ),
    StockQuestion(
      id: 'w3l2q2',
      type: QuestionType.trueFalse,
      concept: 'Current Ratio',
      prompt:
          'A current ratio below 1.0 means a company\'s current liabilities exceed its current assets.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Current Ratio = Current Assets ÷ Current Liabilities. Below 1.0 means the company may struggle to meet short-term obligations with its liquid assets. Generally, above 1.5 is considered healthy.',
      sagePrompt:
          'Explain the current ratio and quick ratio as measures of short-term liquidity.',
    ),
    StockQuestion(
      id: 'w3l2q3',
      type: QuestionType.multipleChoice,
      concept: 'Goodwill',
      prompt: 'Goodwill on a balance sheet represents:',
      options: [
        'Cash held in reserve for emergencies',
        'The premium paid above book value when acquiring another company',
        'Customer satisfaction ratings',
        'The brand value estimated by marketing departments'
      ],
      correctIndex: 1,
      briefExplanation:
          'Goodwill arises in acquisitions when the purchase price exceeds the acquired company\'s net asset value. It reflects intangibles like brand, customer relationships, and synergies.',
      sagePrompt:
          'Explain goodwill impairment and why large write-downs can signal overpaying for acquisitions.',
    ),
    StockQuestion(
      id: 'w3l2q4',
      type: QuestionType.multipleChoice,
      concept: 'Debt-to-Equity',
      prompt:
          'A company has \$200M in debt and \$100M in equity. Its Debt-to-Equity ratio is:',
      options: ['0.5', '1.0', '2.0', '3.0'],
      correctIndex: 2,
      briefExplanation:
          'D/E = Total Debt ÷ Total Equity = \$200M ÷ \$100M = 2.0. A high D/E ratio means the company is heavily leveraged, which amplifies both profits and risks.',
      sagePrompt:
          'Explain the debt-to-equity ratio and how to interpret high vs low leverage for different industries.',
    ),
    StockQuestion(
      id: 'w3l2q5',
      type: QuestionType.trueFalse,
      concept: 'Book Value',
      prompt: 'A company\'s book value always equals its market value.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Book value (accounting value of equity) rarely equals market value. Growth companies often trade far above book value (high P/B), while distressed companies may trade below it.',
      sagePrompt:
          'Explain why market value and book value differ and what a very high or low P/B ratio implies.',
    ),
    StockQuestion(
      id: 'w3l2q6',
      type: QuestionType.multipleChoice,
      concept: 'Working Capital',
      prompt: 'Working capital is defined as:',
      options: [
        'Total assets minus total liabilities',
        'Current assets minus current liabilities',
        'Cash plus short-term investments',
        'Revenue minus operating expenses'
      ],
      correctIndex: 1,
      briefExplanation:
          'Working Capital = Current Assets - Current Liabilities. Positive working capital means the company can fund its day-to-day operations. Negative working capital can indicate cash flow stress.',
      sagePrompt:
          'Explain working capital and why changes in working capital affect cash flow.',
    ),
    StockQuestion(
      id: 'w3l2q7',
      type: QuestionType.multipleChoice,
      concept: 'Retained Earnings',
      prompt: 'Retained earnings on the balance sheet represent:',
      options: [
        'Cash held in a savings account',
        'Cumulative net income kept in the business rather than paid as dividends',
        'Revenue from new product lines',
        'Proceeds from recent stock issuances'
      ],
      correctIndex: 1,
      briefExplanation:
          'Retained earnings grow when the company is profitable and doesn\'t pay all earnings as dividends. They represent the total historical earnings reinvested back into the business.',
      sagePrompt:
          'Explain retained earnings and how they connect the income statement to the balance sheet.',
    ),
    StockQuestion(
      id: 'w3l2q8',
      type: QuestionType.trueFalse,
      concept: 'Intangible Assets',
      prompt:
          'Patents, trademarks, and brand value are examples of intangible assets.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Intangible assets have value but no physical form. They include patents, trademarks, copyrights, software, customer lists, and goodwill. For tech and pharma companies, intangibles can dwarf physical assets.',
      sagePrompt:
          'Explain intangible assets and why they are increasingly important in the modern economy.',
    ),
    StockQuestion(
      id: 'w3l2q9',
      type: QuestionType.multipleChoice,
      concept: 'Share Buybacks on Balance Sheet',
      prompt:
          'When a company buys back its own shares, what happens on the balance sheet?',
      options: [
        'Assets increase and equity increases',
        'Assets decrease (cash paid out) and equity decreases (treasury stock)',
        'Only the number of shares changes, nothing on the balance sheet',
        'Liabilities increase to fund the buyback'
      ],
      correctIndex: 1,
      briefExplanation:
          'Buybacks reduce cash (an asset) and create treasury stock (a contra-equity account that reduces equity). This can improve EPS by reducing share count but also makes the balance sheet more leveraged.',
      sagePrompt:
          'Explain the balance sheet impact of share buybacks and why heavily bought-back companies sometimes have negative book value.',
    ),
  ];

  // ── W3 L3 — Cash Flow ─────────────────────────────────────────────────────
  static final List<StockQuestion> _w3l3Questions = [
    StockQuestion(
      id: 'w3l3q0',
      type: QuestionType.multipleChoice,
      concept: 'Cash Flow Statement',
      prompt:
          'The cash flow statement is divided into three sections. Which is NOT one of them?',
      options: [
        'Operating activities',
        'Investing activities',
        'Financing activities',
        'Marketing activities'
      ],
      correctIndex: 3,
      briefExplanation:
          'The three sections of the cash flow statement are: Operating (core business cash), Investing (capital expenditures, acquisitions), and Financing (debt, dividends, share issuances). Marketing is not a section.',
      sagePrompt:
          'Explain the three sections of the cash flow statement and what each tells you.',
    ),
    StockQuestion(
      id: 'w3l3q1',
      type: QuestionType.multipleChoice,
      concept: 'Free Cash Flow',
      prompt: 'Free Cash Flow (FCF) is calculated as:',
      options: [
        'Net Income + Depreciation',
        'Operating Cash Flow - Capital Expenditures',
        'Revenue - Operating Expenses',
        'EBITDA - Interest Expense'
      ],
      correctIndex: 1,
      briefExplanation:
          'FCF = Operating Cash Flow - CapEx. It represents cash the company generates after maintaining and investing in its asset base — the cash truly available for dividends, buybacks, or debt repayment.',
      sagePrompt:
          'Explain free cash flow and why many investors consider it more important than net income.',
    ),
    StockQuestion(
      id: 'w3l3q2',
      type: QuestionType.trueFalse,
      concept: 'Earnings vs Cash Flow',
      prompt:
          'A company can report positive net income while simultaneously running out of cash.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Accrual accounting allows revenue to be recorded before cash is received and expenses to be deferred. A profitable company can become insolvent if it cannot collect receivables or manage working capital.',
      sagePrompt:
          'Explain the difference between accrual accounting and cash accounting and why cash flow matters.',
    ),
    StockQuestion(
      id: 'w3l3q3',
      type: QuestionType.multipleChoice,
      concept: 'CapEx',
      prompt: 'Capital Expenditures (CapEx) represent:',
      options: [
        'Cash spent on employee salaries',
        'Cash invested in long-term physical assets like equipment and buildings',
        'Marketing and advertising spending',
        'Dividend payments to shareholders'
      ],
      correctIndex: 1,
      briefExplanation:
          'CapEx is spending on long-term tangible assets that will be used over multiple years. High CapEx industries (airlines, telecoms) have less free cash flow than asset-light businesses (software, consulting).',
      sagePrompt:
          'Explain CapEx-intensive vs asset-light business models and their different FCF characteristics.',
    ),
    StockQuestion(
      id: 'w3l3q4',
      type: QuestionType.multipleChoice,
      concept: 'Depreciation',
      prompt:
          'Depreciation is added back to net income when calculating operating cash flow because:',
      options: [
        'It is a cash expense that must be refunded',
        'It is a non-cash charge that reduced net income but didn\'t use cash',
        'It represents cash set aside for future investments',
        'Regulators require it to be excluded'
      ],
      correctIndex: 1,
      briefExplanation:
          'Depreciation reduces reported earnings but is not a cash outflow. When reconciling from net income to cash flow, non-cash charges like depreciation are added back.',
      sagePrompt:
          'Explain depreciation, amortization, and why they are added back in cash flow from operations.',
    ),
    StockQuestion(
      id: 'w3l3q5',
      type: QuestionType.trueFalse,
      concept: 'FCF Yield',
      prompt:
          'FCF yield is calculated by dividing free cash flow per share by the stock price.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'FCF Yield = FCF Per Share ÷ Stock Price. Like a dividend yield, it shows how much cash return investors get per dollar invested. Higher FCF yield can indicate undervaluation.',
      sagePrompt:
          'Explain FCF yield and how to use it as a valuation and screening tool.',
    ),
    StockQuestion(
      id: 'w3l3q6',
      type: QuestionType.multipleChoice,
      concept: 'Cash Conversion Cycle',
      prompt: 'A shorter Cash Conversion Cycle (CCC) generally means:',
      options: [
        'The company takes longer to collect from customers',
        'The company converts its investments into cash more efficiently',
        'The company pays suppliers faster than industry average',
        'The company has more inventory on hand'
      ],
      correctIndex: 1,
      briefExplanation:
          'CCC measures how quickly a company turns inventory and receivables into cash. Amazon famously has a negative CCC — customers pay before Amazon pays suppliers, funding its own growth.',
      sagePrompt:
          'Explain the Cash Conversion Cycle and how companies like Amazon use negative CCC as a competitive advantage.',
    ),
    StockQuestion(
      id: 'w3l3q7',
      type: QuestionType.multipleChoice,
      concept: 'Capital Allocation',
      prompt: 'Which of the following is NOT a use of free cash flow?',
      options: [
        'Paying dividends to shareholders',
        'Buying back shares',
        'Reinvesting in the business',
        'Recording depreciation on assets'
      ],
      correctIndex: 3,
      briefExplanation:
          'Depreciation is a non-cash accounting entry, not a use of cash. Companies can use FCF for dividends, buybacks, acquisitions, debt repayment, or reinvestment in growth.',
      sagePrompt:
          'Explain capital allocation decisions and how to evaluate management\'s effectiveness at deploying cash.',
    ),
    StockQuestion(
      id: 'w3l3q8',
      type: QuestionType.trueFalse,
      concept: 'Owner Earnings',
      prompt:
          'Warren Buffett\'s concept of "owner earnings" adjusts reported earnings for maintenance CapEx needs.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Buffett\'s owner earnings = Net Income + D&A - Required CapEx for maintenance. It approximates true economic earnings available to owners, stripping out CapEx that is not truly discretionary.',
      sagePrompt:
          'Explain Buffett\'s concept of owner earnings and how it differs from reported EPS.',
    ),
    StockQuestion(
      id: 'w3l3q9',
      type: QuestionType.multipleChoice,
      concept: 'Dividend Coverage',
      prompt: 'A dividend coverage ratio below 1.0 means:',
      options: [
        'The company is paying less than 100% of earnings as dividends',
        'The company is paying more in dividends than it earns — unsustainable',
        'The dividend yield is very high',
        'The stock is a good buy for income investors'
      ],
      correctIndex: 1,
      briefExplanation:
          'Coverage Ratio = EPS ÷ Dividend Per Share. Below 1.0 means dividends exceed earnings — the company is dipping into cash reserves or borrowing to fund dividends, which is not sustainable.',
      sagePrompt:
          'Explain dividend coverage ratio and payout ratio as measures of dividend sustainability.',
    ),
  ];

  // ── W3 L4 — Sector Analysis ───────────────────────────────────────────────
  static final List<StockQuestion> _w3l4Questions = [
    StockQuestion(
      id: 'w3l4q0',
      type: QuestionType.multipleChoice,
      concept: 'GICS Sectors',
      prompt:
          'The Global Industry Classification Standard (GICS) divides the market into how many sectors?',
      options: ['6', '8', '11', '15'],
      correctIndex: 2,
      briefExplanation:
          'GICS has 11 sectors: Energy, Materials, Industrials, Consumer Discretionary, Consumer Staples, Healthcare, Financials, Information Technology, Communication Services, Utilities, and Real Estate.',
      sagePrompt: 'Explain the 11 GICS sectors and their characteristics.',
    ),
    StockQuestion(
      id: 'w3l4q1',
      type: QuestionType.multipleChoice,
      concept: 'Cyclical Sectors',
      prompt:
          'Which sector is most sensitive to the economic cycle (most cyclical)?',
      options: [
        'Utilities',
        'Consumer Staples',
        'Consumer Discretionary',
        'Healthcare'
      ],
      correctIndex: 2,
      briefExplanation:
          'Consumer Discretionary (luxury goods, travel, restaurants) is highly cyclical — when the economy slows and people lose jobs, discretionary spending is cut first. Staples and utilities are defensive.',
      sagePrompt:
          'Explain cyclical vs defensive sectors and how they perform differently through economic cycles.',
    ),
    StockQuestion(
      id: 'w3l4q2',
      type: QuestionType.trueFalse,
      concept: 'Defensive Sectors',
      prompt:
          'Utilities and Consumer Staples tend to outperform the market during recessions.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'Defensive sectors provide essential goods/services (electricity, food, medicine) that people need regardless of economic conditions. They hold up better in downturns but lag in bull markets.',
      sagePrompt:
          'Explain defensive sectors and the trade-off between downside protection and upside participation.',
    ),
    StockQuestion(
      id: 'w3l4q3',
      type: QuestionType.multipleChoice,
      concept: 'Interest Rate Sensitivity',
      prompt: 'Rising interest rates tend to hurt which sector most?',
      options: ['Energy', 'Technology', 'Utilities', 'Materials'],
      correctIndex: 2,
      briefExplanation:
          'Utilities carry heavy debt loads and pay high dividends. Rising rates make their bonds less attractive vs fixed income alternatives, and increase borrowing costs — making utilities highly rate-sensitive.',
      sagePrompt:
          'Explain interest rate sensitivity across sectors and how rate changes affect sector rotation.',
    ),
    StockQuestion(
      id: 'w3l4q4',
      type: QuestionType.multipleChoice,
      concept: 'Sector Rotation',
      prompt: 'Sector rotation refers to:',
      options: [
        'Companies changing the industry they operate in',
        'Investors shifting money between sectors as economic conditions change',
        'Index providers rebalancing sector weights annually',
        'Companies rotating executives between departments'
      ],
      correctIndex: 1,
      briefExplanation:
          'Sector rotation is a strategy where investors shift capital between sectors based on the economic cycle. Early cycle favors Financials and Consumer Discretionary; late cycle favors Energy and Materials.',
      sagePrompt:
          'Explain the sector rotation model and which sectors outperform in each phase of the economic cycle.',
    ),
    StockQuestion(
      id: 'w3l4q5',
      type: QuestionType.trueFalse,
      concept: 'Technology Sector',
      prompt:
          'Google (Alphabet) and Meta are classified in the Technology sector of the S&P 500.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Google and Meta are in the Communication Services sector (since the 2018 GICS reclassification), not Technology. Apple, Microsoft, and NVIDIA are in the Technology sector.',
      sagePrompt:
          'Explain the 2018 GICS reclassification and why sector classification affects index investing.',
    ),
    StockQuestion(
      id: 'w3l4q6',
      type: QuestionType.multipleChoice,
      concept: 'Energy Sector',
      prompt: 'The Energy sector\'s performance is most closely tied to:',
      options: [
        'Interest rate levels',
        'Oil and natural gas commodity prices',
        'Consumer confidence readings',
        'Technology adoption rates'
      ],
      correctIndex: 1,
      briefExplanation:
          'Energy companies\' revenues and profits are directly tied to oil and gas prices. When oil rises, energy stocks typically surge; when oil falls, they underperform significantly.',
      sagePrompt:
          'Explain the relationship between commodity prices and energy sector performance.',
    ),
    StockQuestion(
      id: 'w3l4q7',
      type: QuestionType.multipleChoice,
      concept: 'Financial Sector',
      prompt: 'Bank stocks typically benefit from:',
      options: [
        'Low interest rates and a flat yield curve',
        'Rising interest rates and a steep yield curve',
        'Deflation and declining loan demand',
        'Government bond buying programs'
      ],
      correctIndex: 1,
      briefExplanation:
          'Banks borrow short-term and lend long-term. A steep yield curve (long rates much higher than short rates) means a wider net interest margin — the core source of bank profitability.',
      sagePrompt:
          'Explain the yield curve and net interest margin and why they drive bank profitability.',
    ),
    StockQuestion(
      id: 'w3l4q8',
      type: QuestionType.trueFalse,
      concept: 'Healthcare Defensiveness',
      prompt:
          'Healthcare is considered a defensive sector because medical spending is largely non-discretionary.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'People need healthcare regardless of economic conditions, making it relatively defensive. However, it also has growth characteristics due to aging demographics and innovation, making it a hybrid defensive-growth sector.',
      sagePrompt:
          'Explain the healthcare sector\'s unique combination of defensive and growth characteristics.',
    ),
    StockQuestion(
      id: 'w3l4q9',
      type: QuestionType.multipleChoice,
      concept: 'Diversification',
      prompt: 'Owning stocks in all 11 GICS sectors provides:',
      options: [
        'A guaranteed positive return each year',
        'Sector diversification but still leaves investors exposed to overall market risk',
        'Complete protection against market downturns',
        'The same return as holding only the Technology sector'
      ],
      correctIndex: 1,
      briefExplanation:
          'Sector diversification reduces the risk of any single sector declining sharply. However, in severe market downturns, correlations rise and most sectors fall together — sector diversification does not eliminate systematic market risk.',
      sagePrompt:
          'Explain the limits of diversification and the difference between systematic and unsystematic risk.',
    ),
  ];
}
