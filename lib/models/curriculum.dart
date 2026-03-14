import 'package:flutter/material.dart';
import 'models.dart';

class Curriculum {
  static List<World> get worlds => [_world1, _world2, _world3];

  // ── Placeholder question generator ────────────────────────────────────────
  static List<StockQuestion> _placeholder(int n, String prefix) {
    const concepts = [
      'Market Mechanics',
      'Price Discovery',
      'Volatility',
      'Liquidity',
      'Market Hours',
      'Settlement',
      'Margin',
      'Short Interest',
      'Options Basics',
      'Futures',
      'Index Funds',
      'Sector Rotation',
      'Earnings Season',
      'Fed Policy',
      'Inflation',
      'Interest Rates',
      'Currency Risk',
      'Geopolitical Risk',
      'Stock Splits',
      'Buybacks',
    ];
    return List.generate(
        n,
        (i) => StockQuestion(
              id: '${prefix}_$i',
              type: i % 4 == 0
                  ? QuestionType.trueFalse
                  : QuestionType.multipleChoice,
              concept: concepts[i % concepts.length],
              prompt:
                  'Which statement best describes ${concepts[i % concepts.length]}?',
              options: ['Option A', 'Correct Answer', 'Option C', 'Option D'],
              correctIndex: 1,
              briefExplanation:
                  'Understanding ${concepts[i % concepts.length]} is essential to how markets operate.',
              sagePrompt:
                  'Explain ${concepts[i % concepts.length]} using real S&P 500 data and historical charts.',
            ));
  }

  // ── WORLD 1 — Market Basics (Jungle Island) ───────────────────────────────
  static final World _world1 = World(
    index: 0,
    title: 'Market Basics',
    subtitle: 'How stocks & markets work',
    imagePath: 'assets/images/world1.png',
    difficulty: Difficulty.beginner,
    accentColor: const Color(0xFF00FFB2),
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
        questions: _placeholder(20, 'w1l1'),
      ),
      Level(
        id: 'w1l2',
        title: 'Bull & Bear Markets',
        subtitle: 'Market cycles',
        worldIndex: 0,
        levelIndex: 2,
        questions: _placeholder(20, 'w1l2'),
      ),
      Level(
        id: 'w1l3',
        title: 'Market Indices',
        subtitle: 'S&P 500, Dow, NASDAQ',
        worldIndex: 0,
        levelIndex: 3,
        questions: _placeholder(20, 'w1l3'),
      ),
      Level(
        id: 'w1l4',
        title: 'Orders & Trades',
        subtitle: 'Market vs limit orders',
        worldIndex: 0,
        levelIndex: 4,
        questions: _placeholder(20, 'w1l4'),
      ),
    ],
  );

  // ── WORLD 2 — Reading the Tape (Medieval Town) ────────────────────────────
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
          questions: _placeholder(20, 'w2l0')),
      Level(
          id: 'w2l1',
          title: 'Volume & Momentum',
          subtitle: 'What volume tells you',
          worldIndex: 1,
          levelIndex: 1,
          questions: _placeholder(20, 'w2l1')),
      Level(
          id: 'w2l2',
          title: 'Support & Resistance',
          subtitle: 'Key price levels',
          worldIndex: 1,
          levelIndex: 2,
          questions: _placeholder(20, 'w2l2')),
      Level(
          id: 'w2l3',
          title: 'Moving Averages',
          subtitle: 'SMA, EMA & crossovers',
          worldIndex: 1,
          levelIndex: 3,
          questions: _placeholder(20, 'w2l3')),
      Level(
          id: 'w2l4',
          title: 'Chart Patterns',
          subtitle: 'H&S, triangles & flags',
          worldIndex: 1,
          levelIndex: 4,
          questions: _placeholder(20, 'w2l4')),
    ],
  );

  // ── WORLD 3 — Fundamentals (Finance City) ────────────────────────────────
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
          questions: _placeholder(20, 'w3l0')),
      Level(
          id: 'w3l1',
          title: 'Valuation Ratios',
          subtitle: 'P/E, P/B, P/S & EV/EBITDA',
          worldIndex: 2,
          levelIndex: 1,
          questions: _placeholder(20, 'w3l1')),
      Level(
          id: 'w3l2',
          title: 'Balance Sheet',
          subtitle: 'Assets, liabilities & equity',
          worldIndex: 2,
          levelIndex: 2,
          questions: _placeholder(20, 'w3l2')),
      Level(
          id: 'w3l3',
          title: 'Cash Flow',
          subtitle: 'FCF & capital allocation',
          worldIndex: 2,
          levelIndex: 3,
          questions: _placeholder(20, 'w3l3')),
      Level(
          id: 'w3l4',
          title: 'Sector Analysis',
          subtitle: 'Cyclical vs defensive',
          worldIndex: 2,
          levelIndex: 4,
          questions: _placeholder(20, 'w3l4')),
    ],
  );

  // ── World 1 Level 0 — full 20 questions ──────────────────────────────────
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
        'Board member'
      ],
      correctIndex: 1,
      briefExplanation:
          'Shareholders own a slice of the company — entitled to profits and voting rights.',
      sagePrompt:
          'Explain stock ownership using a real S&P 500 company. Show price history.',
    ),
    StockQuestion(
      id: 'w1l0q1',
      type: QuestionType.trueFalse,
      concept: 'Limited Liability',
      prompt:
          'If a company goes bankrupt, shareholders can lose MORE than the amount they invested.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Limited liability means the most you can lose is your investment — not your personal assets.',
      sagePrompt:
          'Explain limited liability with a historical S&P 500 bankruptcy example.',
    ),
    StockQuestion(
      id: 'w1l0q2',
      type: QuestionType.multipleChoice,
      concept: 'Market Cap',
      prompt:
          'A company has 10 million shares at \$50 each. Its market cap is:',
      options: ['\$50 million', '\$500 million', '\$5 billion', '\$50 billion'],
      correctIndex: 1,
      briefExplanation:
          'Market cap = share price × total shares. 10M × \$50 = \$500M.',
      sagePrompt:
          'Explain market cap with examples from large-cap S&P 500 companies.',
    ),
    StockQuestion(
      id: 'w1l0q3',
      type: QuestionType.multipleChoice,
      concept: 'IPO',
      prompt:
          'The first time a company sells its shares to the public is called:',
      options: [
        'A secondary offering',
        'An IPO',
        'A stock split',
        'A dividend'
      ],
      correctIndex: 1,
      briefExplanation:
          'IPO = Initial Public Offering. The company\'s stock market debut.',
      sagePrompt:
          'Explain what an IPO is and show post-IPO price performance of a notable company.',
    ),
    StockQuestion(
      id: 'w1l0q4',
      type: QuestionType.multipleChoice,
      concept: 'Dividends',
      prompt: 'Which of these is NOT a reason companies issue stock?',
      options: [
        'Raise capital for growth',
        'Repay bank loans directly',
        'Reward early investors',
        'Fund acquisitions'
      ],
      correctIndex: 1,
      briefExplanation:
          'Stock issuance raises equity capital — it is separate from loan repayment.',
      sagePrompt:
          'Explain why companies go public and how equity capital differs from debt.',
    ),
    StockQuestion(
      id: 'w1l0q5',
      type: QuestionType.trueFalse,
      concept: 'Voting Rights',
      prompt: 'All shares of a company always give equal voting rights.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Many companies issue Class A and Class B shares with different voting powers (e.g. Google, Meta).',
      sagePrompt:
          'Explain dual-class share structures with real S&P 500 examples.',
    ),
    StockQuestion(
      id: 'w1l0q6',
      type: QuestionType.multipleChoice,
      concept: 'Stock Split',
      prompt:
          'Apple does a 4-for-1 stock split. If you had 10 shares at \$400, you now have:',
      options: [
        '10 shares at \$100',
        '40 shares at \$100',
        '40 shares at \$400',
        '10 shares at \$1,600'
      ],
      correctIndex: 1,
      briefExplanation:
          'A 4-for-1 split multiplies your shares by 4 and divides price by 4. Total value unchanged.',
      sagePrompt:
          'Explain stock splits using Apple\'s actual split history and AAPL price chart.',
    ),
    StockQuestion(
      id: 'w1l0q7',
      type: QuestionType.multipleChoice,
      concept: 'Float',
      prompt: 'The "float" of a stock refers to:',
      options: [
        'Total shares ever issued',
        'Shares available to the public to trade',
        'Shares owned by insiders',
        'Daily trading volume'
      ],
      correctIndex: 1,
      briefExplanation:
          'Float = shares outstanding minus restricted/insider shares. Low float = high volatility.',
      sagePrompt: 'Explain float vs shares outstanding with S&P 500 examples.',
    ),
    StockQuestion(
      id: 'w1l0q8',
      type: QuestionType.trueFalse,
      concept: 'Share Dilution',
      prompt:
          'When a company issues new shares, existing shareholders\' ownership percentage decreases.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'New share issuances dilute existing shareholders unless they buy proportionally more.',
      sagePrompt:
          'Explain dilution with a real S&P 500 example and the stock price impact.',
    ),
    StockQuestion(
      id: 'w1l0q9',
      type: QuestionType.multipleChoice,
      concept: 'Buybacks',
      prompt: 'A company buying back its own shares typically signals:',
      options: [
        'The company is struggling',
        'Management thinks shares are undervalued',
        'The company must pay more dividends',
        'Regulatory requirements'
      ],
      correctIndex: 1,
      briefExplanation:
          'Buybacks reduce share count, boost EPS, and signal management confidence.',
      sagePrompt:
          'Explain share buybacks with major S&P 500 buyback programs and their price impact.',
    ),
    StockQuestion(
      id: 'w1l0q10',
      type: QuestionType.multipleChoice,
      concept: 'Capital Structure',
      prompt: 'In a bankruptcy liquidation, who gets paid FIRST?',
      options: [
        'Common shareholders',
        'Preferred shareholders',
        'Bond holders',
        'Employees'
      ],
      correctIndex: 2,
      briefExplanation:
          'Priority: Bond holders → Preferred shareholders → Common shareholders.',
      sagePrompt:
          'Explain the capital structure waterfall in bankruptcies with a real example.',
    ),
    StockQuestion(
      id: 'w1l0q11',
      type: QuestionType.trueFalse,
      concept: 'Zero Sum',
      prompt:
          'Stock investing is a zero-sum game — for every winner there must be an equal loser.',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Stocks can create wealth as company earnings grow — unlike futures which are zero-sum.',
      sagePrompt:
          'Explain why stock markets are positive-sum over long periods using S&P 500 historical returns.',
    ),
    StockQuestion(
      id: 'w1l0q12',
      type: QuestionType.multipleChoice,
      concept: 'Bid-Ask Spread',
      prompt: 'The "bid" price is:',
      options: [
        'The price sellers are asking',
        'The highest price a buyer will pay',
        'The last trade price',
        'The average of open & close'
      ],
      correctIndex: 1,
      briefExplanation:
          'Bid = what buyers will pay. Ask = what sellers want. The spread is the market maker\'s profit.',
      sagePrompt:
          'Explain bid-ask spread and how it affects trading costs for S&P 500 stocks vs small-caps.',
    ),
    StockQuestion(
      id: 'w1l0q13',
      type: QuestionType.multipleChoice,
      concept: 'Liquidity',
      prompt: 'Which stock is likely MORE liquid?',
      options: [
        'A company with 100K daily trades',
        'Apple with 50M+ daily trades',
        'A penny stock with no volume',
        'A private company'
      ],
      correctIndex: 1,
      briefExplanation:
          'Liquidity means you can buy or sell quickly without moving the price. High volume = high liquidity.',
      sagePrompt:
          'Explain stock liquidity using Apple and a low-liquidity stock for comparison.',
    ),
    StockQuestion(
      id: 'w1l0q14',
      type: QuestionType.trueFalse,
      concept: 'After-Hours Trading',
      prompt:
          'Stock prices can only change during official market hours (9:30am–4pm ET).',
      options: ['True', 'False'],
      correctIndex: 1,
      briefExplanation:
          'Pre-market and after-hours sessions allow price changes outside regular hours.',
      sagePrompt:
          'Explain after-hours trading and show examples where S&P 500 earnings caused big moves.',
    ),
    StockQuestion(
      id: 'w1l0q15',
      type: QuestionType.multipleChoice,
      concept: 'Ticker Symbol',
      prompt: 'Which of these is the correct ticker for Apple Inc.?',
      options: ['APL', 'AAPL', 'APPL', 'APLE'],
      correctIndex: 1,
      briefExplanation:
          'AAPL is Apple\'s NASDAQ ticker. Tickers are unique short codes identifying public companies.',
      sagePrompt:
          'Explain ticker symbols and show AAPL historical price chart with key milestones.',
    ),
    StockQuestion(
      id: 'w1l0q16',
      type: QuestionType.multipleChoice,
      concept: '52-Week Range',
      prompt: 'A stock\'s "52-week high" is:',
      options: [
        'Its price 52 weeks ago',
        'The highest price traded in the past year',
        'Its all-time high',
        'Projected price in 52 weeks'
      ],
      correctIndex: 1,
      briefExplanation:
          'The 52-week range shows volatility over the past year — a key technical reference.',
      sagePrompt:
          'Explain 52-week highs/lows using real S&P 500 stocks and their technical significance.',
    ),
    StockQuestion(
      id: 'w1l0q17',
      type: QuestionType.trueFalse,
      concept: 'DRIP',
      prompt:
          'A Dividend Reinvestment Plan (DRIP) automatically uses dividends to buy more shares.',
      options: ['True', 'False'],
      correctIndex: 0,
      briefExplanation:
          'DRIPs automatically compound returns by purchasing fractional shares with dividends.',
      sagePrompt:
          'Explain DRIPs and model the compounding effect over 20 years using a real S&P 500 dividend stock.',
    ),
    StockQuestion(
      id: 'w1l0q18',
      type: QuestionType.multipleChoice,
      concept: 'ETF',
      prompt: 'An ETF (Exchange-Traded Fund) is:',
      options: [
        'A single stock tracking one company',
        'A basket of securities traded like a stock',
        'A type of bond',
        'A government savings account'
      ],
      correctIndex: 1,
      briefExplanation:
          'ETFs bundle many securities into one tradeable asset — great for diversification.',
      sagePrompt:
          'Explain ETFs vs individual stocks and compare SPY performance vs picking individual stocks.',
    ),
    StockQuestion(
      id: 'w1l0q19',
      type: QuestionType.multipleChoice,
      concept: 'Short Selling',
      prompt: 'When you "short" a stock, you profit when:',
      options: [
        'The stock price rises',
        'The stock price falls',
        'The stock pays a dividend',
        'The company is acquired'
      ],
      correctIndex: 1,
      briefExplanation:
          'Shorting = borrow shares, sell them, buy back cheaper. You profit from price declines.',
      sagePrompt:
          'Explain short selling with a real S&P 500 example and the risks involved.',
    ),
  ];
}
