import qrcode

# Data for QR codes
data_event_match = {
    "event": "BODA_LUISAYROD_291224",
    "guest": "juan1",
    "table": "1",
    "confirmed": "Yes"
}

data_event_no_match = {
    "event": "otro_evento",
    "guest": "juanX",
    "table": "2",
    "confirmed": "No"
}

# Generate QR codes
qr_event_match = qrcode.make(data_event_match)
qr_event_no_match = qrcode.make(data_event_no_match)

# Save QR codes as PNG files
qr_event_match_path = "/mnt/data/qr_event_match.png"
qr_event_no_match_path = "/mnt/data/qr_event_no_match.png"

qr_event_match.save(qr_event_match_path)
qr_event_no_match.save(qr_event_no_match_path)

qr_event_match_path, qr_event_no_match_path
