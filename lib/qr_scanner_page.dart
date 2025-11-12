import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jan_yared/core/constants.dart';
import 'package:jan_yared/providors/auth_providor.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Stop the scanner
    _controller.stop();

    // Process the scanned code
    _processQRCode(code);
  }

  void _processQRCode(String code) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final sessionId = auth.sessionId;
      final employeeId = auth.user!.employeeId;

      if (sessionId == null ) return;

      final baseUrl = ApiConstants.baseUrl;

      // Extract project_id from QR
      final projectId = code.split('project_id=')[1].split('/')[0];

      // Current datetime
      final now = DateTime.now();
final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
final checkIn = formatter.format(now);
final checkOut = formatter.format(now.add(const Duration(hours: 2)));
      // Create attendance report line
      final response = await http.post(
        Uri.parse("$baseUrl/web/dataset/call_kw"),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        body: jsonEncode({
          "jsonrpc": "2.0",
          "method": "call",
          "params": {
            "model": "hr.attendance",
            "method": "create",
            "args": [
              {
                'employee_id':employeeId,
                "project_id": int.parse(
                  projectId,
                ), 
                "check_in": checkIn,
                "check_out": checkOut,
              
              },
            ],
             "kwargs": {},
          },
          "id": 1,
        }),
      );

      debugPrint("Attendance creation response: ${response.body}");

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Attendance Scanned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QR Code scanned successfully!'),
              const SizedBox(height: 8),
              Text('Project ID: $projectId'),
              Text('Check-in: $checkIn'),
              Text('Check-out: $checkOut'),
              const SizedBox(height: 8),
              Text(
                'Success!!',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error processing QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record attendance')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _controller.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),
          // Scanning frame overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Instructions overlay
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Position the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
