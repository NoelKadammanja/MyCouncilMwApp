import 'database_helper.dart';

class UserDao {
  /// Accepts either a full login payload (with top-level `user` and `portifolio`) or a user map.
  Future<void> saveUser(Map<String, dynamic> loginPayload, [String? token]) async {
    final db = await DatabaseHelper.database;
    await db.delete('user');

    // If a full payload was provided, extract the `user` map, otherwise assume payload is the user map itself
    final Map<String, dynamic> userPayload = loginPayload.containsKey('user') && loginPayload['user'] is Map
        ? Map<String, dynamic>.from(loginPayload['user'])
        : Map<String, dynamic>.from(loginPayload);

    // Handle both old and new response structures
    final id = userPayload['id'] ??
        userPayload['ID'] ??
        userPayload['user_id'] ??
        loginPayload['userId']; // New structure

    final name = userPayload['name'] ??
        userPayload['full_name'] ??
        loginPayload['fullName'] ?? ''; // New structure

    final email = userPayload['email'] ??
        loginPayload['email'] ?? ''; // New structure

    final clientId = userPayload['client_id'] ??
        userPayload['clientID'] ??
        userPayload['clientId'] ?? '';

    final natNumber = userPayload['Nat_number'] ??
        userPayload['nat_number'] ??
        userPayload['NatNumber'] ?? '';

    final status = userPayload['status']?.toString() ?? '';
    final emailVerifiedAt = userPayload['email_verified_at']?.toString();
    final createdAt = userPayload['created_at']?.toString();
    final updatedAt = userPayload['updated_at']?.toString();

    // Handle token from new structure
    final tok = token ??
        loginPayload['token']?.toString() ??
        userPayload['token']?.toString() ?? '';

    // New fields from inspection system login response
    final role = loginPayload['role'] ?? userPayload['role'] ?? '';
    final councilId = loginPayload['council'] != null && loginPayload['council'] is Map
        ? loginPayload['council']['id']?.toString() ?? ''
        : '';
    final councilName = loginPayload['council'] != null && loginPayload['council'] is Map
        ? loginPayload['council']['name']?.toString() ?? ''
        : '';
    final councilCode = loginPayload['council'] != null && loginPayload['council'] is Map
        ? loginPayload['council']['code']?.toString() ?? ''
        : '';
    final departmentId = loginPayload['department'] != null && loginPayload['department'] is Map
        ? loginPayload['department']['id']?.toString() ?? ''
        : '';
    final departmentName = loginPayload['department'] != null && loginPayload['department'] is Map
        ? loginPayload['department']['name']?.toString() ?? ''
        : '';

    await db.insert('user', {
      'id': id,
      'name': name,
      'email': email,
      'client_id': clientId,
      'nat_number': natNumber,
      'status': status,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'token': tok,
      'role': role,
      'council_id': councilId,
      'council_name': councilName,
      'council_code': councilCode,
      'department_id': departmentId,
      'department_name': departmentName,
      'last_refresh': DateTime.now().millisecondsSinceEpoch,
    });

    // If portfolio present in the login payload, persist it as well
    try {
      final portfolio = loginPayload['portifolio'] ?? loginPayload['portfolio'];
      if (portfolio is Map) {
        final clientIdFromPayload = clientId.isNotEmpty
            ? clientId
            : (portfolio['client_id'] ?? portfolio['clientID'] ?? portfolio['clientId'])?.toString() ?? '';

        final moneyMarket = portfolio['money_market'] ?? portfolio['moneyMarket'];
        if (moneyMarket is List) {
          await saveMoneyMarketList(moneyMarket, clientIdFromPayload);
        }

        final gov = portfolio['government_securities'] ?? portfolio['governmentSecurities'] ?? portfolio['treasury_notes'];
        if (gov is List) {
          await saveGovernmentSecuritiesList(gov, clientIdFromPayload);
        }

        final shares = portfolio['shares'] ?? portfolio['equity'] ?? portfolio['share_list'];
        if (shares is List) {
          await saveSharesList(shares, clientIdFromPayload);
        }
      }
    } catch (e) {
      // swallow — saving portfolio should not break login persistence
      print('Error persisting portfolio in saveUser: $e');
    }
  }

  Future<void> saveMoneyMarketList(List<dynamic> items, String clientId) async {
    final db = await DatabaseHelper.database;
    await db.delete('money_market', where: 'client_id = ?', whereArgs: [clientId]);

    final now = DateTime.now().millisecondsSinceEpoch;

    for (var item in items) {
      if (item is Map) {
        String type = _pickString(item, ['Type', 'type', 'instrument']);
        String startDate = _pickString(item, ['Start Date', 'start_date', 'startDate']);
        String maturityDate = _pickString(item, ['Maturity Date', 'maturity_date', 'maturityDate']);

        double invested = _pickNum(item, ['Invested Amount (MK)', 'invested_amount']) ?? 0.0;
        double rate = _pickNum(item, ['Rate %', 'rate']) ?? 0.0;
        double accrued = _pickNum(item, ['Accrued Interest (MK)', 'accrued_interest']) ?? 0.0;
        double currentValue = _pickNum(item, ['Current Value (MK)', 'current_value']) ?? 0.0;

        // ✅ NEW: tenure (days)
        int tenureDays =
            _pickNum(item, ['Tenure (days)', 'tenure_days'])?.toInt() ?? 0;

        String source = _pickString(item, ['source_pdf', 'Source_pdf', 'source']);

        await db.insert('money_market', {
          'client_id': clientId,
          'type': type,
          'start_date': startDate,
          'maturity_date': maturityDate,
          'invested_amount': invested,
          'rate': rate,
          'accrued_interest': accrued,
          'current_value': currentValue,
          'tenure_days': tenureDays, // ✅ SAVED
          'source_pdf': source,
          'last_refresh': now,
        });
      }
    }
  }

  Future<void> saveGovernmentSecuritiesList(List<dynamic> items, String clientId) async {
    final db = await DatabaseHelper.database;
    await db.delete('government_securities', where: 'client_id = ?', whereArgs: [clientId]);

    final now = DateTime.now().millisecondsSinceEpoch;
    for (var item in items) {
      if (item is Map) {
        String instrument = _pickString(item, ['Type', 'type', 'Instrument', 'instrument_type']);
        String startDate = _pickString(item, ['Start Date', 'start_date']);
        String maturityDate = _pickString(item, ['Maturity Date', 'maturity_date']);
        double invested = _pickNum(item, ['Invested Amount (MK)', 'invested_amount']) ?? 0.0;
        double rate = _pickNum(item, ['Rate %', 'rate']) ?? 0.0;
        double accrued = _pickNum(item, ['Accrued Interest (MK)', 'accrued_interest']) ?? 0.0;
        double currentValue = _pickNum(item, ['Current Value (MK)', 'current_value']) ?? 0.0;
        String source = _pickString(item, ['source_pdf', 'Source_pdf', 'source']);

        await db.insert('government_securities', {
          'client_id': clientId,
          'instrument_type': instrument,
          'start_date': startDate,
          'maturity_date': maturityDate,
          'invested_amount': invested,
          'rate': rate,
          'accrued_interest': accrued,
          'current_value': currentValue,
          'source_pdf': source,
          'last_refresh': now,
        });
      }
    }
  }

  Future<void> saveSharesList(List<dynamic> items, String clientId) async {
    final db = await DatabaseHelper.database;
    await db.delete('shares', where: 'client_id = ?', whereArgs: [clientId]);

    final now = DateTime.now().millisecondsSinceEpoch;

    for (var item in items) {
      if (item is Map) {
        String counter = _pickString(item, ['Counter', 'counter', 'name']);

        int numShares =
            _pickNum(item, ['Number of Shares', 'number_of_shares'])?.toInt() ?? 0;

        double purchasePrice =
            _pickNum(item, ['Purchase Price (MK)', 'Purchase Price', 'purchase_price']) ?? 0.0;

        double purchaseCost =
            _pickNum(item, ['Purchase Cost (MK)', 'Purchase Cost', 'purchase_cost']) ?? 0.0;

        // ✅ FIXED
        double currentPrice =
            _pickNum(item, ['Current Price (MK)', 'Current Price', 'current_price']) ?? 0.0;

        // ✅ FIXED
        double gainLoss =
            _pickNum(item, ['Gain / (Loss)', 'Gain/Loss', 'gain_loss']) ?? 0.0;

        // ✅ FIXED
        double currentValue =
            _pickNum(item, ['Value (MK)', 'Current Value (MK)', 'current_value']) ?? 0.0;

        await db.insert('shares', {
          'client_id': clientId,
          'counter': counter,
          'number_of_shares': numShares,
          'purchase_price': purchasePrice,
          'purchase_cost': purchaseCost,
          'current_price': currentPrice,
          'gain_loss': gainLoss,
          'current_value': currentValue,
          'last_refresh': now,
        });
      }
    }
  }

  String _pickString(Map m, List<String> keys) {
    for (var k in keys) {
      if (m.containsKey(k) && m[k] != null) return m[k].toString();
    }
    return '';
  }

  double? _pickNum(Map m, List<String> keys) {
    for (var k in keys) {
      if (m.containsKey(k) && m[k] != null) {
        final val = m[k];

        // Already numeric
        if (val is num) return val.toDouble();

        String s = val.toString().trim();
        if (s.isEmpty) return null;

        // Remove currency & spaces
        s = s
            .replaceAll('MK', '')
            .replaceAll('\u00A0', '')
            .replaceAll(',', '')
            .trim();

        // ✅ ACCOUNTING FORMAT: (123.45) → -123.45
        bool isNegative = s.startsWith('(') && s.endsWith(')');

        if (isNegative) {
          s = s.substring(1, s.length - 1);
        }

        final parsed = double.tryParse(s);
        if (parsed == null) return null;

        return isNegative ? -parsed : parsed;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await DatabaseHelper.database;
    final result = await db.query('user', limit: 1);
    if (result.isNotEmpty) {
      return Map<String, dynamic>.from(result.first);
    }
    return null;
  }

  Future<String?> getToken() async {
    final user = await getUser();
    return user?['token']?.toString();
  }

  Future<String?> getUserId() async {
    final user = await getUser();
    return user?['id']?.toString();
  }

  Future<String?> getUserRole() async {
    final user = await getUser();
    return user?['role']?.toString();
  }

  Future<Map<String, dynamic>?> getUserCouncil() async {
    final user = await getUser();
    if (user != null && user['council_id'] != null) {
      return {
        'id': user['council_id'],
        'name': user['council_name'],
        'code': user['council_code'],
      };
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserDepartment() async {
    final user = await getUser();
    if (user != null && user['department_id'] != null) {
      return {
        'id': user['department_id'],
        'name': user['department_name'],
      };
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null && user['token'] != null && user['token'].toString().isNotEmpty;
  }

  Future<double> _sumTableCurrentValue(String table, [String? clientId]) async {
    final db = await DatabaseHelper.database;
    List<Map<String, Object?>> res;
    if (clientId != null && clientId.isNotEmpty) {
      res = await db.rawQuery('SELECT SUM(current_value) as total FROM $table WHERE client_id = ?', [clientId]);
    } else {
      res = await db.rawQuery('SELECT SUM(current_value) as total FROM $table');
    }
    if (res.isNotEmpty) {
      final val = res.first['total'];
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }
    return 0.0;
  }

  Future<double> getMoneyMarketTotal([String? clientId]) async {
    return await _sumTableCurrentValue('money_market', clientId);
  }

  Future<List<Map<String, dynamic>>> getMoneyMarketList([String? clientId]) async {
    final db = await DatabaseHelper.database;
    List<Map<String, Object?>> res;
    if (clientId != null && clientId.isNotEmpty) {
      res = await db.query('money_market', where: 'client_id = ?', whereArgs: [clientId]);
    } else {
      res = await db.query('money_market');
    }
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<double> getGovernmentSecuritiesTotal([String? clientId]) async {
    return await _sumTableCurrentValue('government_securities', clientId);
  }

  Future<List<Map<String, dynamic>>> getGovernmentSecuritiesList([String? clientId]) async {
    final db = await DatabaseHelper.database;
    List<Map<String, Object?>> res;
    if (clientId != null && clientId.isNotEmpty) {
      res = await db.query('government_securities', where: 'client_id = ?', whereArgs: [clientId]);
    } else {
      res = await db.query('government_securities');
    }
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<double> getSharesTotal([String? clientId]) async {
    return await _sumTableCurrentValue('shares', clientId);
  }

  Future<List<Map<String, dynamic>>> getSharesList([String? clientId]) async {
    final db = await DatabaseHelper.database;
    List<Map<String, Object?>> res;
    if (clientId != null && clientId.isNotEmpty) {
      res = await db.query('shares', where: 'client_id = ?', whereArgs: [clientId]);
    } else {
      res = await db.query('shares');
    }
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<double> getTotalPortfolio([String? clientId]) async {
    final mm = await getMoneyMarketTotal(clientId);
    final gov = await getGovernmentSecuritiesTotal(clientId);
    final sh = await getSharesTotal(clientId);
    return mm + gov + sh;
  }

  Future<void> clear() async {
    final db = await DatabaseHelper.database;
    await db.delete('user');
  }
}