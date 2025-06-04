// lib/screens/pdf_utils.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:open_file/open_file.dart';

/// Formats a phone number by removing non-digits, keeping the first 3 and last 3 digits,
/// and replacing the middle with '****'.
String formatPhoneNumber(String phone) {
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 7) {
    return digits;
  }
  String firstPart = digits.substring(0, 3);
  String lastPart = digits.substring(digits.length - 3);
  return '$firstPart****$lastPart';
}

/// Edits and saves a bank transfer PDF using the 'sample.pdf' template.
Future<String> editAndSaveBankTransferPdf(
  Map<String, dynamic> transactionData,
  BuildContext context,
) async {
  try {
    final data = await rootBundle.load('assets/pdf/sample.pdf');
    final pdfBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final document = PdfDocument(inputBytes: pdfBytes);
    final form = document.form;

    if (form.fields.count == 0) {
      throw Exception('No form fields found in sample.pdf.');
    }

    const accountField = 'account';
    const dateField = 'date';
    const priceField = 'price';
    const stampField = 'stamp';
    const discountField = 'discount';
    const serviceField = 'service';
    const vatField = 'vat';
    const totalField = 'total';
    const totalwordsField = 'totalwords';
    const bankNameField = 'bankName';
    const receiptNumberField = 'receiptNumber';

    PdfTextBoxField? accountTextField;
    PdfTextBoxField? dateTextField;
    PdfTextBoxField? priceTextField;
    PdfTextBoxField? stampTextField;
    PdfTextBoxField? discountTextField;
    PdfTextBoxField? serviceTextField;
    PdfTextBoxField? vatTextField;
    PdfTextBoxField? totalTextField;
    PdfTextBoxField? totalwordsTextField;
    PdfTextBoxField? bankNameTextField;
    PdfTextBoxField? receiptNumberTextField;

    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        switch (field.name) {
          case accountField:
            accountTextField = field;
            break;
          case dateField:
            dateTextField = field;
            break;
          case priceField:
            priceTextField = field;
            break;
          case stampField:
            stampTextField = field;
            break;
          case discountField:
            discountTextField = field;
            break;
          case serviceField:
            serviceTextField = field;
            break;
          case vatField:
            vatTextField = field;
            break;
          case totalField:
            totalTextField = field;
            break;
          case totalwordsField:
            totalwordsTextField = field;
            break;
          case bankNameField:
            bankNameTextField = field;
            break;
          case receiptNumberField:
            receiptNumberTextField = field;
            break;
        }
      }
    }

    final missing = <String>[];
    if (accountTextField == null) missing.add(accountField);
    if (dateTextField == null) missing.add(dateField);
    if (priceTextField == null) missing.add(priceField);
    if (stampTextField == null) missing.add(stampField);
    if (discountTextField == null) missing.add(discountField);
    if (serviceTextField == null) missing.add(serviceField);
    if (vatTextField == null) missing.add(vatField);
    if (totalTextField == null) missing.add(totalField);
    if (totalwordsTextField == null) missing.add(totalwordsField);
    if (bankNameTextField == null) missing.add(bankNameField);
    if (receiptNumberTextField == null) missing.add(receiptNumberField);

    if (missing.isNotEmpty) {
      throw Exception(
        'Missing form fields in sample.pdf: ${missing.join(', ')}',
      );
    }

    final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final textColor = PdfColor(0, 0, 0);
    for (final f in [
      accountTextField,
      dateTextField,
      priceTextField,
      stampTextField,
      discountTextField,
      serviceTextField,
      vatTextField,
      totalTextField,
      totalwordsTextField,
      bankNameTextField,
      receiptNumberTextField,
    ]) {
      f!
        ..font = font
        ..foreColor = textColor;
    }

    final baseAmountStr = transactionData['amount'] ?? '0.00';
    final baseAmount = double.tryParse(baseAmountStr) ?? 0.0;
    final serviceFee =
        double.tryParse(transactionData['serviceFee'] ?? '0.00') ?? 0.0;
    final vatAmount =
        double.tryParse(transactionData['vatAmount'] ?? '0.00') ?? 0.0;
    final totalAmount = baseAmount + serviceFee + vatAmount;

    final totalBirr = totalAmount.toInt();
    final totalCents = ((totalAmount - totalBirr) * 100).round();
    final totalBirrWords = NumberToWordsEnglish.convert(totalBirr);
    final totalCentsWords = NumberToWordsEnglish.convert(totalCents);
    final totalInWords =
        totalCents > 0
            ? ' $totalBirrWords birr and $totalCentsWords cents'
            : ' $totalBirrWords birr';

    accountTextField!.text =
        '${transactionData['accountNumber'] ?? ''} ${transactionData['name'] ?? ''}';
    dateTextField!.text = transactionData['transactionTime'] ?? '';
    priceTextField!.text = '$baseAmountStr Birr';
    stampTextField!.text = '0.00 Birr';
    discountTextField!.text =
        '${transactionData['discountAmount'] ?? '0.00'} Birr';
    serviceTextField!.text = '${transactionData['serviceFee']} Birr';
    vatTextField!.text = '${transactionData['vatAmount']} Birr';
    totalTextField!.text = '${totalAmount.toStringAsFixed(2)} Birr';
    totalwordsTextField!.text = totalInWords;
    bankNameTextField!.text = transactionData['bankName'] ?? '';
    receiptNumberTextField!.text = transactionData['receiptNumber'] ?? '';

    document.form.flattenAllFields();
    final bytes = await document.save();
    document.dispose();

    String dirPath;
    if (Platform.isAndroid) {
      dirPath = '/storage/emulated/0/Download';
      final dir = Directory(dirPath);
      if (!await dir.exists()) await dir.create(recursive: true);
    } else {
      dirPath = (await getApplicationDocumentsDirectory()).path;
    }

    final filePath =
        '$dirPath/bank_receipt_${transactionData['transactionNumber']}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Receipt saved to $dirPath')));
      await OpenFile.open(filePath);
    }

    return filePath;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving Bank Transfer PDF: $e')),
      );
    }
    print('Error saving Bank Transfer PDF: $e');
    return '';
  }
}

/// Edits and saves a confirmation PDF using the 'sample_two.pdf' template,
/// and returns the file path of the saved PDF.
Future<String> editAndSaveConfirmationPdf(
  Map<String, dynamic> transactionData,
  BuildContext context,
) async {
  try {
    final data = await rootBundle.load('assets/pdf/sample_two.pdf');
    final pdfBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final document = PdfDocument(inputBytes: pdfBytes);
    final form = document.form;
    if (form.fields.count == 0) {
      throw Exception('No form fields found in sample_two.pdf.');
    }

    const accountNameField = 'accountName'; // Payer's name
    const accountField = 'account'; // Phone number (telebirr no.)
    const receiptNumberField = 'receiptNumber';
    const dateField = 'date';
    const priceField = 'price';
    const stampField = 'stamp';
    const discountField = 'discount';
    const serviceField = 'service';
    const vatField = 'vat';
    const totalField = 'total';
    const totalwordsField = 'totalwords';

    PdfTextBoxField? accountNameTextField;
    PdfTextBoxField? accountTextField;
    PdfTextBoxField? receiptNumberTextField;
    PdfTextBoxField? dateTextField;
    PdfTextBoxField? priceTextField;
    PdfTextBoxField? stampTextField;
    PdfTextBoxField? discountTextField;
    PdfTextBoxField? serviceTextField;
    PdfTextBoxField? vatTextField;
    PdfTextBoxField? totalTextField;
    PdfTextBoxField? totalwordsTextField;

    for (int i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        switch (field.name) {
          case accountNameField:
            accountNameTextField = field;
            break;
          case accountField:
            accountTextField = field;
            break;
          case receiptNumberField:
            receiptNumberTextField = field;
            break;
          case dateField:
            dateTextField = field;
            break;
          case priceField:
            priceTextField = field;
            break;
          case stampField:
            stampTextField = field;
            break;
          case discountField:
            discountTextField = field;
            break;
          case serviceField:
            serviceTextField = field;
            break;
          case vatField:
            vatTextField = field;
            break;
          case totalField:
            totalTextField = field;
            break;
          case totalwordsField:
            totalwordsTextField = field;
            break;
        }
      }
    }

    final missingFields = <String>[];
    if (accountNameTextField == null) missingFields.add(accountNameField);
    if (accountTextField == null) missingFields.add(accountField);
    if (receiptNumberTextField == null) missingFields.add(receiptNumberField);
    if (dateTextField == null) missingFields.add(dateField);
    if (priceTextField == null) missingFields.add(priceField);
    if (stampTextField == null) missingFields.add(stampField);
    if (discountTextField == null) missingFields.add(discountField);
    if (serviceTextField == null) missingFields.add(serviceField);
    if (vatTextField == null) missingFields.add(vatField);
    if (totalTextField == null) missingFields.add(totalField);
    if (totalwordsTextField == null) missingFields.add(totalwordsField);

    if (missingFields.isNotEmpty) {
      throw Exception(
        'Missing fields in sample_two.pdf: ${missingFields.join(', ')}',
      );
    }

    final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final textColor = PdfColor(0, 0, 0);
    for (final f in [
      accountNameTextField,
      accountTextField,
      receiptNumberTextField,
      dateTextField,
      priceTextField,
      stampTextField,
      discountTextField,
      serviceTextField,
      vatTextField,
      totalTextField,
      totalwordsTextField,
    ]) {
      f!
        ..font = font
        ..foreColor = textColor;
    }

    final baseAmountStr = transactionData['amount'] ?? '0.00';
    final serviceFeeStr = transactionData['serviceFee'] ?? '0.00';
    final vatAmountStr = transactionData['vatAmount'] ?? '0.00';
    final baseAmount = double.tryParse(baseAmountStr) ?? 0.0;
    final serviceFeeVal = double.tryParse(serviceFeeStr) ?? 0.0;
    final vatAmountVal = double.tryParse(vatAmountStr) ?? 0.0;
    final totalAmount = baseAmount + serviceFeeVal + vatAmountVal;
    final totalBirr = totalAmount.toInt();
    final totalCents = ((totalAmount - totalBirr) * 100).round();
    final totalBirrWords = NumberToWordsEnglish.convert(totalBirr);
    final totalCentsWords = NumberToWordsEnglish.convert(totalCents);
    final totalAmountInWords =
        totalCents > 0
            ? ' $totalBirrWords birr and $totalCentsWords cents'
            : ' $totalBirrWords birr';

    accountNameTextField!.text = transactionData['name'] ?? '';
    accountTextField!.text = formatPhoneNumber(
      transactionData['accountNumber'] ?? '',
    );
    receiptNumberTextField!.text = transactionData['receiptNumber'] ?? '';
    dateTextField!.text = transactionData['transactionTime'] ?? 'N/A';
    priceTextField!.text = '$baseAmountStr Birr';
    stampTextField!.text = '0.00 Birr';
    discountTextField!.text =
        '${transactionData['discountAmount'] ?? '0.00'} Birr';
    serviceTextField!.text = '$serviceFeeStr Birr';
    vatTextField!.text = '$vatAmountStr Birr';
    totalTextField!.text = '${totalAmount.toStringAsFixed(2)} Birr';
    totalwordsTextField!.text = totalAmountInWords;

    document.form.flattenAllFields();
    final bytes = await document.save();
    document.dispose();

    String dirPath;
    if (Platform.isAndroid) {
      dirPath = '/storage/emulated/0/Download';
      final dir = Directory(dirPath);
      if (!await dir.exists()) await dir.create(recursive: true);
    } else {
      dirPath = (await getApplicationDocumentsDirectory()).path;
    }

    final file = File(
      '$dirPath/confirmation_receipt_${transactionData['transactionNumber']}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmation PDF saved to $dirPath')),
      );
      await OpenFile.open(file.path);
    }

    return file.path;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving Confirmation PDF: $e')),
      );
    }
    print('Error saving Confirmation PDF: $e');
    return '';
  }
}

/// Edits and saves a merchant confirmation PDF using the 'sample_three.pdf' template.
/// Edits and saves a merchant confirmation PDF using the 'sample_three.pdf' template,
/// and returns the file path of the saved PDF.
Future<String> editAndSaveMerchantConfirmationPdf(
  Map<String, dynamic> transactionData,
  BuildContext context,
) async {
  try {
    // Load the PDF template
    final data = await rootBundle.load('assets/pdf/sample_three.pdf');
    final pdfBytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final document = PdfDocument(inputBytes: pdfBytes);
    final form = document.form;
    if (form.fields.count == 0) {
      throw Exception('No form fields found in sample_three.pdf.');
    }

    // Field names in the PDF
    const accountNameField = 'accountName'; // Merchant ID
    const accountField = 'account'; // Operator ID
    const receiptNumberField = 'receiptNumber';
    const dateField = 'date';
    const priceField = 'price';
    const stampField = 'stamp';
    const discountField = 'discount';
    const serviceField = 'service';
    const vatField = 'vat';
    const totalField = 'total';
    const totalwordsField = 'totalwords';

    // Find each field
    PdfTextBoxField? accountNameTextField;
    PdfTextBoxField? accountTextField;
    PdfTextBoxField? receiptNumberTextField;
    PdfTextBoxField? dateTextField;
    PdfTextBoxField? priceTextField;
    PdfTextBoxField? stampTextField;
    PdfTextBoxField? discountTextField;
    PdfTextBoxField? serviceTextField;
    PdfTextBoxField? vatTextField;
    PdfTextBoxField? totalTextField;
    PdfTextBoxField? totalwordsTextField;

    for (var i = 0; i < form.fields.count; i++) {
      final field = form.fields[i];
      if (field is PdfTextBoxField) {
        switch (field.name) {
          case accountNameField:
            accountNameTextField = field;
            break;
          case accountField:
            accountTextField = field;
            break;
          case receiptNumberField:
            receiptNumberTextField = field;
            break;
          case dateField:
            dateTextField = field;
            break;
          case priceField:
            priceTextField = field;
            break;
          case stampField:
            stampTextField = field;
            break;
          case discountField:
            discountTextField = field;
            break;
          case serviceField:
            serviceTextField = field;
            break;
          case vatField:
            vatTextField = field;
            break;
          case totalField:
            totalTextField = field;
            break;
          case totalwordsField:
            totalwordsTextField = field;
            break;
        }
      }
    }

    // Verify all fields found
    final missing = <String>[];
    if (accountNameTextField == null) missing.add(accountNameField);
    if (accountTextField == null) missing.add(accountField);
    if (receiptNumberTextField == null) missing.add(receiptNumberField);
    if (dateTextField == null) missing.add(dateField);
    if (priceTextField == null) missing.add(priceField);
    if (stampTextField == null) missing.add(stampField);
    if (discountTextField == null) missing.add(discountField);
    if (serviceTextField == null) missing.add(serviceField);
    if (vatTextField == null) missing.add(vatField);
    if (totalTextField == null) missing.add(totalField);
    if (totalwordsTextField == null) missing.add(totalwordsField);
    if (missing.isNotEmpty) {
      throw Exception(
        'Missing fields in sample_three.pdf: ${missing.join(', ')}',
      );
    }

    // Apply font and color
    final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final textColor = PdfColor(0, 0, 0);
    for (final f in [
      accountNameTextField,
      accountTextField,
      receiptNumberTextField,
      dateTextField,
      priceTextField,
      stampTextField,
      discountTextField,
      serviceTextField,
      vatTextField,
      totalTextField,
      totalwordsTextField,
    ]) {
      f!
        ..font = font
        ..foreColor = textColor;
    }

    // Parse amounts
    final baseAmountStr = transactionData['amount'] ?? '0.00';
    final serviceFeeStr = transactionData['serviceFee'] ?? '0.00';
    final vatAmountStr = transactionData['vatAmount'] ?? '0.00';
    final baseAmount = double.tryParse(baseAmountStr) ?? 0.0;
    final serviceFee = double.tryParse(serviceFeeStr) ?? 0.0;
    final vatAmount = double.tryParse(vatAmountStr) ?? 0.0;
    final totalAmount = baseAmount + serviceFee + vatAmount;
    final totalBirr = totalAmount.toInt();
    final totalCents = ((totalAmount - totalBirr) * 100).round();
    final wordsBirr = NumberToWordsEnglish.convert(totalBirr);
    final wordsCents = NumberToWordsEnglish.convert(totalCents);
    final totalInWords =
        totalCents > 0
            ? ' $wordsBirr birr and $wordsCents cents'
            : ' $wordsBirr birr';

    // Fill in the fields
    accountNameTextField!.text = transactionData['merchantId'] ?? '';
    accountTextField!.text = transactionData['operatorId'] ?? '';
    receiptNumberTextField!.text = transactionData['receiptNumber'] ?? '';
    dateTextField!.text = transactionData['transactionTime'] ?? '';
    priceTextField!.text = '$baseAmountStr Birr';
    stampTextField!.text = '0.00 Birr';
    discountTextField!.text =
        '${transactionData['discountAmount'] ?? '0.00'} Birr';
    serviceTextField!.text = '$serviceFeeStr Birr';
    vatTextField!.text = '$vatAmountStr Birr';
    totalTextField!.text = '${totalAmount.toStringAsFixed(2)} Birr';
    totalwordsTextField!.text = totalInWords;

    // Flatten and save
    document.form.flattenAllFields();
    final bytes = await document.save();
    document.dispose();

    // Determine save directory
    String dirPath;
    if (Platform.isAndroid) {
      dirPath = '/storage/emulated/0/Download';
      final dir = Directory(dirPath);
      if (!await dir.exists()) await dir.create(recursive: true);
    } else {
      dirPath = (await getApplicationDocumentsDirectory()).path;
    }

    // Write file
    final file = File(
      '$dirPath/merchant_confirmation_'
      '${transactionData['transactionNumber']}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);

    // Notify and open
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Merchant PDF saved to $dirPath')));
      await OpenFile.open(file.path);
    }

    return file.path;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving Merchant PDF: $e')));
    }
    print('Error saving Merchant PDF: $e');
    return '';
  }
}
