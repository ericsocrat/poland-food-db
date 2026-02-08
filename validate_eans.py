"""
Validate EAN-13 barcodes using checksum algorithm.

EAN-13 checksum calculation (Modulo 10):
1. Sum odd-position digits (1st, 3rd, 5th, ..., 11th) and multiply by 1
2. Sum even-position digits (2nd, 4th, 6th, ..., 12th) and multiply by 3
3. Add both sums
4. Calculate checksum: (10 - (sum % 10)) % 10
5. Compare to 13th digit

Usage:
    python validate_eans.py              # Validate all EANs in database
    python validate_eans.py --ean 5449000130389  # Validate single EAN
"""

import argparse
import sys
from pathlib import Path


def calculate_ean13_checksum(ean_12_digits: str) -> int:
    """
    Calculate the EAN-13 check digit for the first 12 digits.
    
    Args:
        ean_12_digits: First 12 digits of EAN-13 code
        
    Returns:
        Check digit (0-9)
    """
    if len(ean_12_digits) != 12:
        raise ValueError(f"Expected 12 digits, got {len(ean_12_digits)}")
    
    # Sum odd positions (1st, 3rd, 5th, ...) * 1
    odd_sum = sum(int(ean_12_digits[i]) for i in range(0, 12, 2))
    
    # Sum even positions (2nd, 4th, 6th, ...) * 3  
    even_sum = sum(int(ean_12_digits[i]) for i in range(1, 12, 2))
    
    total = odd_sum + (even_sum * 3)
    checksum = (10 - (total % 10)) % 10
    
    return checksum


def validate_ean13(ean: str) -> tuple[bool, str]:
    """
    Validate an EAN-13 barcode.
    
    Args:
        ean: EAN-13 code to validate
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    # Check length
    if len(ean) == 8:
        return (True, "EAN-8 (valid but not EAN-13)")
    
    if len(ean) != 13:
        return (False, f"Invalid length: {len(ean)} (expected 13)")
    
    # Check all digits
    if not ean.isdigit():
        return (False, "Contains non-digit characters")
    
    # Validate checksum
    expected_checksum = calculate_ean13_checksum(ean[:12])
    actual_checksum = int(ean[12])
    
    if expected_checksum != actual_checksum:
        return (False, f"Invalid checksum: expected {expected_checksum}, got {actual_checksum}")
    
    return (True, "Valid EAN-13")


def validate_database_eans():
    """Validate all EANs stored in the database."""
    import subprocess
    import json
    
    # Query database for all EANs
    query = """
        SELECT product_id, brand, product_name, ean
        FROM products
        WHERE ean IS NOT NULL
        ORDER BY brand, product_name;
    """
    
    result = subprocess.run(
        [
            "docker", "exec", "-i", "supabase_db_poland-food-db",
            "psql", "-U", "postgres", "-d", "postgres",
            "-t", "-A", "-F", "|",
            "-c", query
        ],
        capture_output=True,
        text=True,
        encoding="utf-8"
    )
    
    if result.returncode != 0:
        print(f"Error querying database: {result.stderr}", file=sys.stderr)
        return False
    
    lines = [line for line in result.stdout.strip().split('\n') if line]
    
    if not lines:
        print("No EANs found in database")
        return True
    
    print(f"Validating {len(lines)} EAN codes from database...\n")
    
    invalid_count = 0
    valid_count = 0
    
    for line in lines:
        product_id, brand, product_name, ean = line.split('|')
        is_valid, message = validate_ean13(ean)
        
        if is_valid:
            valid_count += 1
            if "EAN-8" in message:
                print(f"⚠️  {brand} - {product_name}")
                print(f"    EAN: {ean} ({message})")
                print()
        else:
            invalid_count += 1
            print(f"❌ {brand} - {product_name}")
            print(f"    EAN: {ean}")
            print(f"    Error: {message}")
            print()
    
    print("=" * 80)
    print(f"Results: {valid_count} valid, {invalid_count} invalid")
    
    if invalid_count > 0:
        print(f"\n❌ Found {invalid_count} invalid EAN codes!")
        return False
    else:
        print(f"\n✅ All EAN codes are valid!")
        return True


def main():
    parser = argparse.ArgumentParser(
        description="Validate EAN-13 barcodes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument(
        "--ean",
        help="Validate a single EAN code"
    )
    
    args = parser.parse_args()
    
    if args.ean:
        # Validate single EAN
        is_valid, message = validate_ean13(args.ean)
        print(f"EAN: {args.ean}")
        print(f"Result: {message}")
        sys.exit(0 if is_valid else 1)
    else:
        # Validate all EANs in database
        success = validate_database_eans()
        sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
