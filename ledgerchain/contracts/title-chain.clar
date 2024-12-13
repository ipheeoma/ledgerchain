;; LedgerChain smart contract: A decentralized proof-of-ownership registry

(define-non-fungible-token property uint)

(define-map property-registry uint 
  {
    current-owner: principal,
    property-info: (string-ascii 256),
    valuation: uint,
    geographic-data: (string-ascii 256),
    zoning-info: (string-ascii 100)
  }
)

(define-data-var property-id-counter uint u0)

;; Function to register a new property
(define-public (register-property 
  (property-info (string-ascii 256)) 
  (valuation uint)
  (geographic-data (string-ascii 256))
  (zoning-info (string-ascii 100))
)
  (let
    (
      (new-property-id (+ (var-get property-id-counter) u1))
    )
    ;; Check if valuation is greater than zero
    (asserts! (> valuation u0) (err u400))
    ;; Check if property-info is not empty
    (asserts! (> (len property-info) u0) (err u401))
    ;; Check if geographic-data is not empty
    (asserts! (> (len geographic-data) u0) (err u407))
    ;; Check if zoning-info is not empty
    (asserts! (> (len zoning-info) u0) (err u408))
    (try! (nft-mint? property new-property-id tx-sender))
    (map-set property-registry new-property-id
      {
        current-owner: tx-sender,
        property-info: property-info,
        valuation: valuation,
        geographic-data: geographic-data,
        zoning-info: zoning-info
      }
    )
    (var-set property-id-counter new-property-id)
    (ok new-property-id)
  )
)

;; Function to transfer property ownership
(define-public (transfer-property (property-id uint) (new-owner principal) (digital-signature (buff 65)))
  (let
    (
      (property-data (unwrap! (map-get? property-registry property-id) (err u404)))
      (current-owner (unwrap! (nft-get-owner? property property-id) (err u404)))
    )
    (asserts! (is-eq tx-sender current-owner) (err u403))
    ;; Check if new-owner is not the current owner
    (asserts! (not (is-eq new-owner current-owner)) (err u405))
    ;; Check if digital-signature is not empty
    (asserts! (> (len digital-signature) u0) (err u406))
    (try! (validate-signature property-id current-owner new-owner digital-signature))
    (try! (nft-transfer? property property-id current-owner new-owner))
    (map-set property-registry property-id
      (merge property-data { current-owner: new-owner })
    )
    (ok true)
  )
)

;; Function to validate signature
(define-private (validate-signature (property-id uint) (current-owner principal) (new-owner principal) (digital-signature (buff 65)))
  (let 
    (
      ;; Create message hash from property ID and new owner
      (message-hash 
        (sha256 
          (concat 
            (uint-to-buff property-id) 
            (principal-to-buff new-owner)
          )
        )
      )
      ;; Attempt to recover the public key
      (recovered-result (secp256k1-recover? message-hash digital-signature))
    )
    (match recovered-result 
      recovered-pubkey 
        (let
          (
            (recovered-principal (unwrap! (principal-of? recovered-pubkey) (err u401)))
          )
          (if (is-eq recovered-principal current-owner)
              (ok true)
              (err u401))
        )
      error-value
        (err u402)
    )
  )
)

;; Function to get property details
(define-read-only (get-property-details (property-id uint))
  (map-get? property-registry property-id)
)

;; Function to update property valuation
(define-public (update-property-valuation (property-id uint) (new-valuation uint))
  (let
    (
      (property-data (unwrap! (map-get? property-registry property-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get current-owner property-data)) (err u403))
    (map-set property-registry property-id
      (merge property-data { valuation: new-valuation })
    )
    (ok true)
  )
)

;; Function to update geographic data
(define-public (update-geographic-data (property-id uint) (new-geographic-data (string-ascii 256)))
  (let
    (
      (property-data (unwrap! (map-get? property-registry property-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get current-owner property-data)) (err u403))
    (asserts! (> (len new-geographic-data) u0) (err u407))
    (map-set property-registry property-id
      (merge property-data { geographic-data: new-geographic-data })
    )
    (ok true)
  )
)

;; Function to update zoning information
(define-public (update-zoning-info (property-id uint) (new-zoning-info (string-ascii 100)))
  (let
    (
      (property-data (unwrap! (map-get? property-registry property-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get current-owner property-data)) (err u403))
    (asserts! (> (len new-zoning-info) u0) (err u408))
    (map-set property-registry property-id
      (merge property-data { zoning-info: new-zoning-info })
    )
    (ok true)
  )
)

;; Function to purchase property using cryptocurrency
(define-public (purchase-property (property-id uint) (crypto-tx-hash (buff 32)))
  (let
    (
      (property-data (unwrap! (map-get? property-registry property-id) (err u404)))
      (seller (unwrap! (nft-get-owner? property property-id) (err u404)))
      (price (get valuation property-data))
    )
    (asserts! (is-valid-crypto-payment? crypto-tx-hash price seller) (err u402))
    (try! (nft-transfer? property property-id seller tx-sender))
    (map-set property-registry property-id
      (merge property-data { current-owner: tx-sender })
    )
    (ok true)
  )
)

;; Helper function to validate cryptocurrency payment (placeholder)
(define-private (is-valid-crypto-payment? (crypto-tx-hash (buff 32)) (expected-amount uint) (recipient principal))
  ;; In a real implementation, this function would verify the cryptocurrency transaction
  ;; For this example, we'll just return true
  true
)

;; Helper function to convert principal to buff
(define-private (principal-to-buff (value principal))
  (unwrap-panic (to-consensus-buff? value))
)

;; Helper function to convert uint to buff
(define-private (uint-to-buff (value uint))
  (unwrap-panic (to-consensus-buff? value))
)

