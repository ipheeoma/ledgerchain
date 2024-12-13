;; Ledgerchain smart contract: A decentralized proof-of-ownership registry

;; Define the asset NFT
(define-non-fungible-token asset uint)

;; Data map to store asset details
(define-map asset-details uint 
  {
    owner: principal,
    description: (string-ascii 256),
    price: uint
  }
)

;; Counter for asset IDs
(define-data-var asset-id-counter uint u0)

;; Function to register a new asset
(define-public (register-asset (description (string-ascii 256)) (price uint))
  (let
    (
      (new-asset-id (+ (var-get asset-id-counter) u1))
    )
    (try! (nft-mint? asset new-asset-id tx-sender))
    (map-set asset-details new-asset-id
      {
        owner: tx-sender,
        description: description,
        price: price
      }
    )
    (var-set asset-id-counter new-asset-id)
    (ok new-asset-id)
  )
)

;; Function to transfer asset ownership
(define-public (transfer-asset (asset-id uint) (recipient principal) (signature (buff 65)))
  (let
    (
      (asset-info (unwrap! (map-get? asset-details asset-id) (err u404)))
      (sender (unwrap! (nft-get-owner? asset asset-id) (err u404)))
    )
    (asserts! (is-eq tx-sender sender) (err u403))
    (asserts! (is-valid-signature? asset-id recipient signature) (err u401))
    (try! (nft-transfer? asset asset-id sender recipient))
    (map-set asset-details asset-id
      (merge asset-info { owner: recipient })
    )
    (ok true)
  )
)

;; Function to verify signature
(define-private (is-valid-signature? (asset-id uint) (recipient principal) (signature (buff 65)))
  (let
    (
      (message (concat (to-uint asset-id) (principal-to-uint256 recipient)))
    )
    (is-eq (secp256k1-recover? message signature) (some (unwrap! (nft-get-owner? asset asset-id) false)))
  )
)

;; Function to get asset details
(define-read-only (get-asset-details (asset-id uint))
  (map-get? asset-details asset-id)
)

;; Function to update asset price
(define-public (update-asset-price (asset-id uint) (new-price uint))
  (let
    (
      (asset-info (unwrap! (map-get? asset-details asset-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner asset-info)) (err u403))
    (map-set asset-details asset-id
      (merge asset-info { price: new-price })
    )
    (ok true)
  )
)

;; Function to buy asset using Bitcoin
(define-public (buy-asset (asset-id uint) (btc-tx (buff 1024)))
  (let
    (
      (asset-info (unwrap! (map-get? asset-details asset-id) (err u404)))
      (seller (unwrap! (nft-get-owner? asset asset-id) (err u404)))
      (price (get price asset-info))
    )
    (asserts! (is-valid-btc-payment? btc-tx price seller) (err u402))
    (try! (nft-transfer? asset asset-id seller tx-sender))
    (map-set asset-details asset-id
      (merge asset-info { owner: tx-sender })
    )
    (ok true)
  )
)

;; Helper function to validate Bitcoin payment (placeholder)
(define-private (is-valid-btc-payment? (btc-tx (buff 1024)) (expected-amount uint) (recipient principal))
  ;; In a real implementation, this function would verify the Bitcoin transaction
  ;; For this example, we'll just return true
  true
)