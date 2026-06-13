<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="com.wms.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) products = java.util.Collections.emptyList();

    ObjectMapper mapper = new ObjectMapper();
    String productsJson = mapper.valueToTree(products).toString();
    request.setAttribute("productsJson", productsJson);
%>
<style>
    @keyframes spin {
        from { transform: rotate(0deg); }
        to   { transform: rotate(360deg); }
    }

    /* ─── Tabs Styling ─── */
    .tabs-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 24px;
        overflow-x: auto;
        padding-bottom: 4px;
    }
    .tab-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 16px;
        font-size: 13px;
        font-weight: 600;
        border: 1px solid var(--border);
        background: #fff;
        color: rgba(16, 55, 92, 0.60);
        cursor: pointer;
        transition: all 0.15s ease;
        border-radius: var(--radius-btn);
        white-space: nowrap;
    }
    .tab-btn:hover {
        border-color: rgba(16, 55, 92, 0.20);
        color: var(--navy);
    }
    .tab-btn.active {
        background: #fff;
        color: var(--navy);
        border-color: rgba(16, 55, 92, 0.20);
        box-shadow: 0 1px 3px rgba(16, 55, 92, 0.05);
    }
    .tab-badge {
        padding: 2px 6px;
        font-size: 10px;
        font-weight: 700;
        border-radius: 4px;
        background: var(--alice);
        color: rgba(16, 55, 92, 0.60);
    }
    .tab-btn.active .tab-badge {
        background: rgba(16, 55, 92, 0.10);
        color: var(--navy);
    }

    /* ─── Create SKU Modal ─── */
    .btn-add-sku {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 9px 18px;
        background: var(--orange);
        border: none;
        border-radius: var(--radius-btn);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s, transform 0.1s;
    }
    .btn-add-sku:hover { background: #ea580c; transform: translateY(-1px); }
    .btn-add-sku:active { transform: translateY(0); }
    .btn-add-sku svg { width: 15px; height: 15px; }

    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(10, 30, 60, 0.45);
        backdrop-filter: blur(4px);
        z-index: 1000;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }
    .modal-overlay.active { display: flex; }
    .modal-box {
        background: #fff;
        border-radius: var(--radius-card);
        width: 100%;
        max-width: 560px;
        max-height: 90vh;
        overflow-y: auto;
        box-shadow: 0 24px 64px rgba(10, 30, 60, 0.20);
        animation: modalSlideIn 0.2s ease;
    }
    @keyframes modalSlideIn {
        from { opacity: 0; transform: translateY(-16px) scale(0.98); }
        to   { opacity: 1; transform: translateY(0) scale(1); }
    }
    .modal-hdr {
        padding: 20px 24px 16px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 16px;
    }
    .modal-title {
        margin: 0;
        font-size: 17px;
        font-weight: 700;
        color: var(--navy);
        line-height: 1.3;
    }
    .modal-subtitle {
        margin: 4px 0 0;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.50);
        line-height: 1.4;
    }
    .modal-close {
        background: none;
        border: none;
        font-size: 22px;
        color: rgba(16, 55, 92, 0.35);
        cursor: pointer;
        padding: 0;
        line-height: 1;
        transition: color 0.15s;
        flex-shrink: 0;
    }
    .modal-close:hover { color: var(--navy); }
    .modal-body {
        padding: 20px 24px;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-label {
        font-size: 12px;
        font-weight: 600;
        color: var(--navy);
        letter-spacing: 0.01em;
    }
    .form-input {
        padding: 9px 12px;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        color: var(--navy);
        outline: none;
        background: #fff;
        transition: border-color 0.15s, box-shadow 0.15s;
    }
    .form-input:focus {
        border-color: rgba(16, 55, 92, 0.35);
        box-shadow: 0 0 0 3px rgba(16, 55, 92, 0.08);
    }
    .form-input::placeholder { color: rgba(16, 55, 92, 0.28); }
    .form-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;
    }
    .modal-note {
        background: rgba(235, 131, 23, 0.08);
        border: 1px solid rgba(235, 131, 23, 0.25);
        border-radius: calc(var(--radius-btn) - 2px);
        padding: 12px 16px;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.70);
        line-height: 1.5;
    }
    .modal-ftr {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        border-radius: 0 0 var(--radius-card) var(--radius-card);
    }
    .category-tree-picker-box {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: 6px;
        padding: 12px 16px;
        min-height: 160px;
        max-height: 260px;
        overflow-y: auto;
    }
    .tree-children-container {
        padding-left: 20px;
        margin-top: 0;
        display: flex;
        flex-direction: column;
        gap: 4px;
        position: relative;
    }
    .tree-node-wrapper { position: relative; }
    .tree-children-container > .tree-node-wrapper::before {
        content: '';
        position: absolute;
        top: 15px;
        left: -10px;
        width: 14px;
        height: 1px;
        border-top: 1px dashed rgba(16, 55, 92, 0.18);
        z-index: 1;
    }
    .tree-children-container > .tree-node-wrapper::after {
        content: '';
        position: absolute;
        top: 0;
        left: -10px;
        width: 1px;
        height: 100%;
        border-left: 1px dashed rgba(16, 55, 92, 0.18);
    }
    .tree-children-container > .tree-node-wrapper:last-child::after { height: 15px; }
    .tree-node {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 7px 10px;
        border-radius: 6px;
        cursor: pointer;
        font-size: 13px;
        color: rgba(16, 55, 92, 0.70);
        transition: background 0.12s, color 0.12s;
        user-select: none;
    }
    .tree-node:hover { background: rgba(16, 55, 92, 0.05); color: var(--navy); }
    .tree-node.selected {
        background: rgba(235, 131, 23, 0.10);
        color: var(--orange);
        font-weight: 600;
    }
    .tree-node.selected .tree-node-label { color: var(--orange); }
    .tree-node-label { flex: 1; }
    .tree-expand-btn {
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 4px;
        transition: transform 0.15s;
        flex-shrink: 0;
    }
    .tree-expand-btn svg { width: 12px; height: 12px; }
    .tree-children { display: flex; flex-direction: column; gap: 4px; }
    .tree-leaf-spacer { width: 20px; flex-shrink: 0; }

    /* ─── Toolbar & Filters ─── */
    .toolbar-wrap {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        padding: 16px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        flex-wrap: wrap;
    }
    .filters-left {
        display: flex;
        align-items: center;
        gap: 12px;
        flex: 1;
        min-width: 280px;
    }
    .search-input-wrap {
        position: relative;
        flex: 1;
        max-width: 320px;
        min-width: 200px;
    }
    .search-input-wrap svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 15px;
        height: 15px;
        color: rgba(16, 55, 92, 0.3);
    }
    .search-input-wrap input {
        width: 100%;
        padding: 8px 16px 8px 36px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        outline: none;
        color: var(--navy);
        transition: border-color 0.15s;
    }
    .search-input-wrap input::placeholder {
        color: rgba(16, 55, 92, 0.3);
    }
    .search-input-wrap input:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    
    .select-wrap {
        position: relative;
    }
    .select-wrap select {
        appearance: none;
        padding: 8px 36px 8px 16px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        outline: none;
        color: var(--navy);
        cursor: pointer;
        font-weight: 500;
    }
    .select-wrap svg {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.4);
        pointer-events: none;
    }

    .btn-export {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-export:hover {
        background: #0d2c4b;
    }
    .btn-export svg {
        width: 14px;
        height: 14px;
    }

    /* ─── Data Table Card ─── */
    .table-card {
        background: #fff;
        border: 1px solid var(--border);
        border-radius: var(--radius-card);
        overflow: hidden;
    }
    .table-scroll {
        overflow-x: auto;
    }
    .sku-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }
    .sku-table th {
        padding: 12px 16px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        color: rgba(16, 55, 92, 0.50);
        background: var(--alice);
        letter-spacing: 0.05em;
        border-bottom: 1px solid var(--border);
    }
    .sku-table th:first-child { padding-left: 20px; }
    .sku-table th:last-child { padding-right: 20px; text-align: center; }
    
    .sku-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #F0F3FA;
        vertical-align: middle;
    }
    .sku-table td:first-child { padding-left: 20px; }
    .sku-table td:last-child { padding-right: 20px; text-align: center; }
    
    .sku-table tr {
        transition: background 0.12s;
    }
    .sku-table tr:hover td {
        background: rgba(240, 244, 250, 0.40);
    }

    /* Table elements */
    .sku-code-cell {
        font-size: 13px;
        font-family: monospace;
        color: var(--navy);
        font-weight: 600;
    }
    .sku-name-cell {
        font-size: 13px;
        font-weight: 500;
        color: var(--navy);
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        max-width: 180px;
    }
    .sku-cat-cell {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
    }

    /* Dimension & weight details */
    .detail-icon-wrap {
        display: flex;
        flex-direction: column;
        gap: 3px;
    }
    .detail-icon-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
        white-space: nowrap;
    }
    .detail-icon-row svg {
        width: 12px;
        height: 12px;
        flex-shrink: 0;
    }

    /* Stock value & Warning */
    .stock-val-wrap {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 6px;
    }
    .stock-val-wrap svg {
        width: 14px;
        height: 14px;
        color: var(--orange);
        flex-shrink: 0;
    }
    .stock-qty {
        font-size: 13px;
        font-weight: 600;
    }
    .stock-qty.low-stock {
        color: var(--orange);
    }
    .stock-qty.normal-stock {
        color: var(--navy);
    }

    /* Storage Locations mapping */
    .loc-tag-wrap {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    .loc-tag {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.75);
    }
    .loc-tag-code {
        font-weight: 700;
        color: #1d4ed8;
    }
    .loc-unassigned {
        color: var(--orange);
        font-size: 12px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }
    .loc-unassigned svg {
        width: 14px;
        height: 14px;
    }

    /* Info cell */
    .info-lbl {
        font-size: 12px;
        color: rgba(16, 55, 92, 0.85);
    }
    .info-lbl-inner {
        font-weight: 500;
    }
    .info-time {
        font-size: 10.5px;
        color: rgba(16, 55, 92, 0.60);
    }

    /* Status Pills */
    .pill-badge {
        display: inline-flex;
        align-items: center;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: 600;
        border-radius: 4px;
        white-space: nowrap;
    }
    .pill-badge.approved {
        background: #ECFDF5;
        color: #047857;
        border: 1px solid rgba(16, 185, 129, 0.20);
    }
    .pill-badge.pending {
        background: #fffbeb;
        color: #b45309;
        border: 1px solid rgba(245, 158, 11, 0.30);
    }
    .pill-badge.rejected {
        background: #fef2f2;
        color: #b91c1c;
        border: 1px solid rgba(239, 68, 68, 0.20);
    }

    /* Action buttons (Approve / Reject) */
    .btn-action {
        width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-action.approve {
        color: #059669;
        background: none;
    }
    .btn-action.approve:hover {
        background: #ECFDF5;
    }
    .btn-action.reject {
        color: #ef4444;
        background: none;
    }
    .btn-action.reject:hover {
        background: #FEF2F2;
    }
    .btn-action svg {
        width: 16px;
        height: 16px;
    }

    /* Table Footer */
    .table-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 14px 24px;
        background: var(--alice);
        font-size: 12px;
        color: rgba(16, 55, 92, 0.60);
        border-top: 1px solid #F0F3FA;
    }

    /* ─── Modals ─── */
    .modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(16, 55, 92, 0.50);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: start;
        justify-content: center;
        z-index: 1000;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s ease;
        overflow-y: auto;
        padding: 32px 16px;
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }
    .modal-box {
        background: #fff;
        width: 100%;
        max-width: 680px;
        border-radius: var(--radius-card);
        box-shadow: 0 20px 25px -5px rgba(16, 55, 92, 0.15), 0 10px 10px -5px rgba(16, 55, 92, 0.1);
        transform: translateY(24px);
        transition: transform 0.2s ease;
        display: flex;
        flex-direction: column;
    }
    .modal-overlay.active .modal-box {
        transform: translateY(0);
    }

    .modal-hdr {
        padding: 20px 24px;
        border-bottom: 1px solid var(--border);
    }
    .modal-hdr-top {
        display: flex;
        align-items: start;
        justify-content: space-between;
    }
    .modal-title {
        color: var(--navy);
        font-size: 18px;
        font-weight: 800;
        line-height: 1.25;
    }
    .modal-subtitle {
        color: rgba(16, 55, 92, 0.50);
        font-size: 13px;
        margin-top: 4px;
    }
    .modal-close {
        background: none;
        border: none;
        cursor: pointer;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        color: rgba(16, 55, 92, 0.3);
        font-size: 20px;
        transition: color 0.15s, background-color 0.15s;
    }
    .modal-close:hover {
        color: rgba(16, 55, 92, 0.7);
        background-color: var(--alice);
    }

    /* Product preview card in modal */
    .sku-preview-card {
        margin-top: 16px;
        display: flex;
        align-items: start;
        gap: 12px;
        background: var(--alice);
        padding: 12px 16px;
        border-radius: 8px;
        border: 1px solid var(--border);
    }
    .sku-preview-icon {
        color: rgba(16, 55, 92, 0.40);
        margin-top: 2px;
        flex-shrink: 0;
    }
    .sku-preview-icon svg {
        width: 20px;
        height: 20px;
    }
    .sku-preview-meta {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12px;
        font-family: monospace;
        color: rgba(16, 55, 92, 0.50);
    }
    .sku-preview-tag {
        padding: 2px 6px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: 4px;
        font-family: var(--font-main);
    }
    .sku-preview-name {
        color: var(--navy);
        font-weight: 600;
        font-size: 14px;
        margin-top: 2px;
    }
    .sku-preview-specs {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-top: 4px;
        font-size: 11px;
        color: rgba(16, 55, 92, 0.40);
    }
    .sku-preview-specs span {
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .sku-preview-specs svg {
        width: 12px;
        height: 12px;
    }

    /* Multi-Location Matrix inside body */
    .matrix-title {
        color: var(--navy);
        font-weight: 700;
        font-size: 13px;
    }
    .matrix-desc {
        color: rgba(16, 55, 92, 0.40);
        font-size: 12px;
        margin-top: 2px;
    }
    .matrix-headers {
        display: grid;
        grid-template-columns: 1fr 1fr auto;
        gap: 12px;
        font-size: 10px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: rgba(16, 55, 92, 0.40);
        padding: 0 4px;
        margin-top: 16px;
    }
    .matrix-headers-col {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .matrix-headers-col svg {
        width: 12px;
        height: 12px;
    }

    .matrix-rows-container {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-top: 8px;
    }
    .matrix-row {
        display: grid;
        grid-template-columns: 1fr 1fr auto;
        gap: 12px;
        align-items: start;
        padding: 12px;
        border-radius: 8px;
        border: 1px solid var(--border);
        background: rgba(240, 244, 250, 0.4);
        transition: border-color 0.15s, background-color 0.15s;
    }
    .matrix-row.duplicate {
        border-color: rgba(239, 68, 68, 0.3);
        background-color: #fef2f2;
    }
    .matrix-row-select-wrap {
        position: relative;
    }
    .matrix-row-select-wrap svg.prefix-icon {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.30);
        pointer-events: none;
    }
    .matrix-row-select-wrap select {
        width: 100%;
        appearance: none;
        padding: 8px 32px 8px 34px;
        background: #fff;
        border: 1px solid #D8E1F0;
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        outline: none;
        color: var(--navy);
        cursor: pointer;
        transition: border-color 0.15s;
    }
    .matrix-row-select-wrap select:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }
    .matrix-row-select-wrap select:disabled {
        background: var(--alice);
        color: rgba(16, 55, 92, 0.3);
        cursor: not-allowed;
        border-color: var(--border);
    }
    .matrix-row-select-wrap svg.suffix-icon {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        width: 14px;
        height: 14px;
        color: rgba(16, 55, 92, 0.30);
        pointer-events: none;
    }
    .matrix-row.duplicate select {
        border-color: #ef4444;
        background-color: #fef2f2;
        color: #b91c1c;
    }
    .matrix-row-err {
        color: #ef4444;
        font-size: 10px;
        margin-top: 4px;
        padding-left: 4px;
    }

    .btn-row-delete {
        width: 32px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background 0.15s, color 0.15s;
        background: none;
        color: rgba(239, 68, 68, 0.50);
    }
    .btn-row-delete:hover:not(:disabled) {
        background: #fef2f2;
        color: #ef4444;
    }
    .btn-row-delete:disabled {
        color: rgba(16, 55, 92, 0.15);
        cursor: not-allowed;
    }
    .btn-row-delete svg {
        width: 14px;
        height: 14px;
    }

    .btn-add-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 10px 16px;
        font-size: 13px;
        font-weight: 600;
        background: #fff;
        color: rgba(16, 55, 92, 0.60);
        border: 1px dashed #C8D3E8;
        border-radius: calc(var(--radius-btn) - 2px);
        width: 100%;
        cursor: pointer;
        transition: all 0.15s ease;
        margin-top: 12px;
    }
    .btn-add-row:hover {
        color: var(--navy);
        border-color: rgba(16, 55, 92, 0.40);
        background: var(--alice);
    }
    .btn-add-row svg {
        width: 16px;
        height: 16px;
    }

    /* Modal footer */
    .modal-ftr {
        padding: 16px 24px;
        border-top: 1px solid var(--border);
        background: var(--alice);
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        border-bottom-left-radius: var(--radius-card);
        border-bottom-right-radius: var(--radius-card);
    }
    .btn-cancel {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 8px 16px;
        background: #fff;
        border: 1px solid var(--border);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-weight: 500;
        color: rgba(16, 55, 92, 0.70);
        cursor: pointer;
        transition: color 0.15s, border-color 0.15s;
    }
    .btn-cancel:hover {
        color: var(--navy);
        border-color: rgba(16, 55, 92, 0.30);
    }
    .btn-submit {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 8px 20px;
        background: var(--navy);
        border: none;
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-weight: 600;
        color: #fff;
        cursor: pointer;
        transition: background 0.15s;
    }
    .btn-submit:hover:not(:disabled) {
        background: #0d2c4b;
    }
    .btn-submit:disabled {
        background: rgba(16, 55, 92, 0.15);
        color: rgba(16, 55, 92, 0.30);
        cursor: not-allowed;
    }

    /* ─── Reject Modal Box ─── */
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    .form-label {
        color: rgba(16, 55, 92, 0.60);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .form-textarea {
        width: 100%;
        min-height: 100px;
        padding: 10px 14px;
        border: 1px solid var(--border);
        background: var(--alice);
        border-radius: calc(var(--radius-btn) - 2px);
        font-size: 13px;
        font-family: inherit;
        color: var(--navy);
        outline: none;
        resize: vertical;
        transition: border-color 0.15s;
    }
    .form-textarea:focus {
        border-color: rgba(16, 55, 92, 0.40);
    }

    /* ─── Toast Notification CSS ─── */
    .toast-notification {
        position: fixed;
        top: 24px;
        right: 24px;
        z-index: 9999;
        background: #10B981;
        color: #fff;
        padding: 12px 24px;
        border-radius: 8px;
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        display: none;
        align-items: center;
        gap: 8px;
        font-weight: 500;
        transition: all 0.3s ease-in-out;
    }
    .toast-notification.show {
        display: flex;
        animation: toastSlideIn 0.3s forwards;
    }
    .toast-notification.error {
        background: #EF4444;
    }
    @keyframes toastSlideIn {
        from { transform: translateY(-20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .btn-act-circle {
        width: 26px;
        height: 26px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        cursor: pointer;
        transition: background 0.15s, color 0.15s;
    }
    .btn-act-circle.edit {
        background: rgba(16, 55, 92, 0.05);
        color: rgba(16, 55, 92, 0.7);
    }
    .btn-act-circle.edit:hover {
        background: rgba(16, 55, 92, 0.1);
        color: var(--navy);
    }
    .btn-act-circle.del {
        background: rgba(239, 68, 68, 0.05);
        color: #ef4444;
    }
    .btn-act-circle.del:hover {
        background: rgba(239, 68, 68, 0.1);
        color: #dc2626;
    }
    .btn-act-circle svg {
        width: 12px;
        height: 12px;
    }
</style>

<!-- Toast Notification Element -->
<div id="skuToast" class="toast-notification">
    <span id="skuToastIcon">✓</span>
    <span id="skuToastMsg">Cập nhật thành công!</span>
</div>

<!-- ══ TABS FILTER SECTION ════════════════════════════════════ -->
<div class="tabs-wrap">
    <button class="tab-btn active" id="tab-all" onclick="window.setSKUTab('all')">
        Tất cả <span class="tab-badge" id="badge-all">0</span>
    </button>
</div>

<!-- ══ TOOLBAR SECTION ═══════════════════════════════════════ -->
<div class="toolbar-wrap">
    <div class="filters-left">
        <!-- Search -->
        <div class="search-input-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"></svg>
            <input type="text" placeholder="Tìm mã SKU, tên sản phẩm..." id="skuSearchInput"/>
        </div>
        
        <!-- Category Select -->
        <div class="select-wrap">
            <select id="skuCategorySelect">
                <option>Tất cả</option>
                <c:forEach var="c" items="${categories}">
                    <option><c:out value="${c.categoryName}"/></option>
                </c:forEach>
            </select>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></svg>
        </div>
    </div>
    
    <button class="btn-export" id="btnExportCSV">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
        Xuất CSV
    </button>

    <!-- Create SKU — only for MANAGER -->
    <c:if test="${loggedInUser.role == 'MANAGER'}">
    <button class="btn-add-sku" id="btnCreateSKUTrigger">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Thêm SKU mới
    </button>
    </c:if>
</div>

<!-- ══ TABLE SECTION ═════════════════════════════════════════ -->
<div class="table-card">
    <div class="table-scroll">
        <table class="sku-table">
            <thead>
                <tr>
                    <th style="width: 130px;">Mã SKU</th>
                    <th style="width: 180px;">Tên sản phẩm</th>
                    <th style="width: 90px;">Danh mục</th>
                    <th style="width: 140px; text-align: center;">KL / Kích thước</th>
                    <th style="width: 90px; text-align: right;">Tồn kho</th>
                    <th style="width: 180px;">Vị trí lưu trữ</th>
                    <th style="width: 185px;">Thông tin</th>
                    <th style="width: 120px; text-align: center;">Thao tác</th>
                </tr>
            </thead>
            <tbody id="skuTableBody"></tbody>
        </table>
    </div>
    
    <div class="table-footer">
        <span id="skuTableInfo">Hiển thị 0 / 0 SKU</span>
    </div>
</div>

<!-- ══ CREATE MODAL ══════════════════════════════════════════ -->
<div class="modal-overlay" id="createModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
                <div>
                <h2 class="modal-title">Tạo Master SKU</h2>
                <p class="modal-subtitle">Khai báo thông tin gốc sản phẩm</p>
                </div>
            <button class="modal-close" id="createModalClose">&times;</button>
            </div>
        <div class="modal-body">
            <div class="form-group">
                <label class="form-label" for="create-sku">Mã SKU *</label>
                <div style="display: flex; gap: 8px; align-items: stretch;">
                    <input class="form-input" type="text" id="create-sku" readonly placeholder="Bấm nút Auto để sinh mã..." style="flex:1; background:rgba(16,55,92,0.03); cursor:not-allowed; font-weight:bold; color:var(--navy);"/>
                    <button type="button" class="btn-export" id="btnAutoGenSku" title="Tự động tạo SKU" style="white-space:nowrap; padding:0 14px; height:38px;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/><polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/><line x1="4" y1="4" x2="9" y2="9"/></svg>
                        Auto
                    </button>
            </div>
                <input type="hidden" id="create-category-id" value=""/>
        </div>
            <div class="form-group">
                <label class="form-label" for="create-name">Tên sản phẩm *</label>
                <input class="form-input" type="text" id="create-name" placeholder="Ví dụ: Lược chải tóc gỡ rối - Màu hồng"/>
            </div>
            <div class="form-group">
                <label class="form-label" style="margin-bottom: 2px;">Danh mục hàng hóa * <span style="font-weight:400; color:rgba(16,55,92,0.40);">(chọn từ cây danh mục bên dưới)</span></label>
                <input type="text" class="form-input" id="selectedCategoryDisplay" readonly placeholder="Nhấp chọn danh mục..." style="cursor:default; font-weight:600; background:#fff;"/>
                <input type="hidden" id="create-category" value=""/>
                <div class="category-tree-picker-box" id="categoryTreePicker"></div>
                </div>
            <div class="form-grid" style="grid-template-columns: 1.8fr 1fr; gap: 12px;">
                <div class="form-group">
                    <label class="form-label">Kích thước (D×R×C) cm</label>
                    <div style="display:flex; gap:6px; align-items:center;">
                        <input class="form-input" type="number" id="create-dim-length" min="0" step="any" placeholder="Dài" style="flex:1; min-width:0; width:0; text-align:center; padding:10px 4px;"/>
                        <span style="color:rgba(16,55,92,0.35); font-size:13px;">×</span>
                        <input class="form-input" type="number" id="create-dim-width"  min="0" step="any" placeholder="Rộng" style="flex:1; min-width:0; width:0; text-align:center; padding:10px 4px;"/>
                        <span style="color:rgba(16,55,92,0.35); font-size:13px;">×</span>
                        <input class="form-input" type="number" id="create-dim-height" min="0" step="any" placeholder="Cao" style="flex:1; min-width:0; width:0; text-align:center; padding:10px 4px;"/>
                </div>
            </div>
                <div class="form-group">
                    <label class="form-label" for="create-weight">Khối lượng (kg)</label>
                    <input class="form-input" type="number" id="create-weight" min="0" step="any" placeholder="VD: 0.28" style="padding:10px 6px; min-width:0; width:100%;"/>
            </div>
        </div>
        <div class="modal-ftr">
            <button class="modal-close btn-export" id="createModalCancel" style="padding:9px 16px;">Hủy</button>
            <button class="btn-add-sku" id="btnCreateSKUSubmit">Tạo SKU</button>
        </div>
    </div>
</div>

<!-- ══ EDIT MODAL ══════════════════════════════════════════ -->
<div class="modal-overlay" id="editModalOverlay">
    <div class="modal-box">
        <div class="modal-hdr">
                <div>
                <h2 class="modal-title">Chỉnh sửa SKU</h2>
                <p class="modal-subtitle" id="edit-sku-code-label">SKU-XXXX</p>
                </div>
            <button class="modal-close" id="editModalClose">&times;</button>
            </div>
        <div class="modal-body">
            <input type="hidden" id="edit-id"/>
            <div class="form-group">
                <label class="form-label" for="edit-name">Tên sản phẩm *</label>
                <input class="form-input" type="text" id="edit-name" placeholder="Tên sản phẩm..."/>
            </div>
            <div class="form-group">
                <label class="form-label" style="margin-bottom: 2px;">Danh mục hàng hóa * <span style="font-weight:400; color:rgba(16,55,92,0.40);">(chọn từ cây danh mục bên dưới)</span></label>
                <input type="text" class="form-input" id="selectedEditCategoryDisplay" readonly placeholder="Nhấp chọn danh mục..." style="cursor:default; font-weight:600; background:#fff;"/>
                <input type="hidden" id="edit-category" value=""/>
                <div class="category-tree-picker-box" id="editCategoryTreePicker"></div>
        </div>
            <div class="form-grid" style="grid-template-columns: 1.8fr 1fr; gap: 12px;">
                <div class="form-group">
                    <label class="form-label">Kích thước (D×R×C) cm</label>
                    <div style="display:flex; gap:6px; align-items:center;">
                        <input class="form-input" type="number" id="edit-dim-length" min="0" step="any" placeholder="Dài" style="flex:1; min-width:0; width:0; text-align:center; padding:10px 4px;"/>
                        <span style="color:rgba(16,55,92,0.35); font-size:13px;">×</span>
                        <input class="form-input" type="number" id="edit-dim-width"  min="0" step="any" placeholder="Rộng" style="flex:1; min-width:0; width:0; text-align:center; padding:10px 4px;"/>
                        <span style="color:rgba(16,55,92,0.35); font-size:13px;">×</span>
                        <input class="form-input" type="number" id="edit-dim-height" min="0" step="any" placeholder="Cao" style="flex:1; min-width:0; width:0; text-align:center; padding:10px 4px;"/>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="edit-weight">Khối lượng (kg)</label>
                    <input class="form-input" type="number" id="edit-weight" min="0" step="any" placeholder="VD: 0.28" style="padding:10px 6px; min-width:0; width:100%;"/>
                </div>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="edit-barcode">Mã vạch (Barcode)</label>
                    <input class="form-input" type="text" id="edit-barcode" placeholder="Barcode..."/>
                </div>
                <div class="form-group">
                    <label class="form-label" for="edit-unit">Đơn vị tính</label>
                    <input class="form-input" type="text" id="edit-unit" placeholder="VD: Cái, Hộp..."/>
                </div>
            </div>
        </div>
        <div class="modal-ftr">
            <button class="btn-cancel" id="editModalCancel">Hủy</button>
            <button class="btn-submit" id="btnEditSKUSubmit">Lưu thay đổi</button>
        </div>
    </div>
</div>

<div id="productsJsonData" style="display:none;"><c:out value="${productsJson}"/></div>
<div id="warehousesJsonData" style="display:none;"><c:out value="${warehousesJson}"/></div>
<div id="categoriesJsonData" style="display:none;"><c:out value="${categoriesJson}"/></div>

<!-- ══ SCRIPT LOGIC ══════════════════════════════════════════ -->
<script>
// Expose JSTL session user details to client-side
window.WMS_USER = {
    fullName: "${fn:escapeXml(not empty loggedInUser.fullName ? loggedInUser.fullName : 'Guest')}",
    role: "${fn:escapeXml(not empty loggedInUser.role ? loggedInUser.role : 'Guest')}"
};

function showToast(message, isError) {
    var toast = document.getElementById("skuToast");
    var msgSpan = document.getElementById("skuToastMsg");
    var iconSpan = document.getElementById("skuToastIcon");
    if (!toast || !msgSpan || !iconSpan) return;

    msgSpan.textContent = message;
    iconSpan.textContent = isError ? "✕" : "✓";
    toast.className = "toast-notification show";
    if (isError) {
        toast.classList.add("error");
    }

    setTimeout(function() {
        toast.classList.remove("show");
    }, 4000);
}

// Check for flash messages from Servlet
(function() {
    var errorMsg = "${fn:escapeXml(errorMessage)}";
    var successMsg = "${fn:escapeXml(successMessage)}";
    if (errorMsg && errorMsg.trim() !== "" && errorMsg.indexOf('errorMessage') === -1) {
        showToast(errorMsg, true);
    } else if (successMsg && successMsg.trim() !== "" && successMsg.indexOf('successMessage') === -1) {
        showToast(successMsg, false);
    }
})();

function submitPostAction(action, params) {
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = window.location.pathname;

    var actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = action;
    form.appendChild(actionInput);

    for (var key in params) {
        if (params.hasOwnProperty(key)) {
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = key;
            input.value = params[key];
            form.appendChild(input);
        }
    }

    document.body.appendChild(form);
    form.submit();
}

(function () {
'use strict';

var skus = [];
try {
    var rawJsonEl = document.getElementById('productsJsonData');
    var rawJson = rawJsonEl ? rawJsonEl.textContent : '';
    if (rawJson && rawJson.trim()) {
        var SERVER_PRODUCTS = JSON.parse(rawJson);
        skus = SERVER_PRODUCTS.map(function(p) {
    return {
                id: 'p-' + (p.productId || 0),
                productId: p.productId || 0,
        sku: p.sku || p.skuCode || '',
        name: p.name || p.productName || '',
                categoryId: p.categoryId,
                barcode: p.barcode || '',
                unit: p.unit || '',
        category: p.category || p.categoryName || '',
        dimensions: p.dimensions || p.attributesText || 'N/A',
        weight: p.weight || (p.weightKg ? p.weightKg + ' kg' : 'N/A'),
        qtyOnHand: typeof p.qtyOnHand !== 'undefined' ? p.qtyOnHand : 0,
        minStock: p.minStock || 0,
        maxStock: p.maxStock || 0,
        locationConfigs: p.locationConfigs || [],
        createdBy: p.creatorName || p.createdBy || '',
        createdAt: p.createdAt || '',
        updatedBy: p.approverName || p.updatedBy || '',
                lastUpdated: p.lastUpdated || p.updatedAt || ''
    };
});
    }
} catch (e) {
    console.warn('master-sku: No server product data');
}


// Bind dynamic warehouses and zones from servlet
var DB_WAREHOUSES = [];
try {
    var rawWhJsonEl = document.getElementById('warehousesJsonData');
    var rawWhJson = rawWhJsonEl ? rawWhJsonEl.textContent : '';
    if (rawWhJson && rawWhJson.trim()) {
        DB_WAREHOUSES = JSON.parse(rawWhJson);
    }
} catch (e) {
    console.warn('master-sku: No server warehouse data');
}

var LOCATIONS = [];
var ZONES = [];
if (DB_WAREHOUSES.length > 0) {
    DB_WAREHOUSES.forEach(function(wh) {
        LOCATIONS.push({
            id: wh.warehouseId.toString(),
            name: wh.warehouseName,
            code: wh.warehouseCode,
            city: wh.address || ""
        });
        if (wh.zones) {
            wh.zones.forEach(function(z) {
                ZONES.push({
                    id: z.zoneId.toString(),
                    locationId: wh.warehouseId.toString(),
                    code: z.zoneCode,
                    name: z.zoneName,
                    allowForNew: z.zoneType === 'NORMAL' || z.zoneType === 'RETURN' || z.zoneType === 'DAMAGED'
                });
            });
        }
    });

}

var DB_CATEGORIES = [];
try {
    var rawCategoriesJsonEl = document.getElementById('categoriesJsonData');
    var rawCategoriesJson = rawCategoriesJsonEl ? rawCategoriesJsonEl.textContent : '';
    if (rawCategoriesJson && rawCategoriesJson.trim()) {
        var parsed = JSON.parse(rawCategoriesJson);
        DB_CATEGORIES = parsed.map(function(c) {
            return {
                categoryId: c.id,
                categoryName: c.name,
                categoryCode: c.code,
                parentId: c.parentId,
                description: c.description,
                immutable: c.immutable,
                active: c.active
            };
        });
    }
} catch (e) {
    console.warn('master-sku: Failed to parse categoriesJson', e);
}

function buildCategoryTreeOptions(categories, isFilter) {
    var html = isFilter ? '<option value="Tất cả">Tất cả</option>' : '';
    
    function recurse(parentId, prefix) {
        var levelNodes = categories.filter(function(c) {
            var nodeParentId = c.parentId;
            if (parentId === null) {
                return nodeParentId === null || nodeParentId === 0 || nodeParentId === 'null';
            }
            return nodeParentId == parentId;
        });
        
        levelNodes.forEach(function(node) {
            html += '<option value="' + escapeHtml(node.categoryName) + '">' + prefix + escapeHtml(node.categoryName) + '</option>';
            recurse(node.categoryId, prefix + '    ');
        });
    }
    
    recurse(null, '');
    return html;
}

function escapeHtml(str) {
    if (!str) return '';
    return str
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

var search = '';
var selectedCategory = 'Tất cả';
var activeTab = 'all'; // 'all' (no more pending/approved/rejected tabs)

/* ─── DOM Elements ───────────────────────────────────────── */
var tableBody   = document.getElementById('skuTableBody');
var tableInfo   = document.getElementById('skuTableInfo');
var searchInput = document.getElementById('skuSearchInput');
var catSelect   = document.getElementById('skuCategorySelect');

if (catSelect && DB_CATEGORIES.length > 0) {
    catSelect.innerHTML = buildCategoryTreeOptions(DB_CATEGORIES, true);
}

/* ─── Create Modal — Category Tree Picker ──────────────────── */
var selectedPickerCategory = '';
var expandedPickerNodes = {};

function renderPickerTree() {
    var pickerContainer = document.getElementById('categoryTreePicker');
    if (!pickerContainer) return;

    var roots = DB_CATEGORIES.filter(function (c) {
        return c.parentId === null || c.parentId === 0 || c.parentId === 'null';
    });

    if (roots.length === 0) {
        pickerContainer.innerHTML = '<div style="color:rgba(16,55,92,0.4);text-align:center;padding:24px;">Chưa có danh mục nào.</div>';
        return;
    }

    function buildPickerNodeHtml(node, level) {
        var children = DB_CATEGORIES.filter(function (c) { return c.parentId === node.categoryId; });
        var hasChildren = children.length > 0;

        if (expandedPickerNodes[node.categoryId] === undefined) {
            expandedPickerNodes[node.categoryId] = true;
        }
        var isExpanded = expandedPickerNodes[node.categoryId];
        var isSelected = selectedPickerCategory === node.categoryName;
        var indent = level * 16;

        var html = '<div class="tree-node-wrapper">';
        html += '<div class="tree-node' + (isSelected ? ' selected' : '') + '"'
            + ' onclick="window.selectPickerCategory(decodeURIComponent(\'' + encodeURIComponent(node.categoryName) + '\'))"'
            + ' style="padding-left:' + indent + 'px">';

        if (hasChildren) {
            html += '<span class="tree-expand-btn"'
                + ' onclick="event.stopPropagation();window.togglePickerNode(' + node.categoryId + ')">'
                + '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"'
                + ' style="transform:rotate(' + (isExpanded ? '90deg' : '0deg') + ');transition:transform 0.15s">'
                + '<polyline points="9 18 15 12 9 6"/></svg></span>';
            } else {
            html += '<span class="tree-leaf-spacer"></span>';
        }

        html += '<span class="tree-node-label">' + escapeHtml(node.categoryName) + '</span>';
        html += '</div>';

        if (hasChildren && isExpanded) {
            html += '<div class="tree-children">';
            children.forEach(function (child) {
                html += buildPickerNodeHtml(child, level + 1);
            });
            html += '</div>';
        }

        html += '</div>';
        return html;
    }

    var html = '<div style="display:flex;flex-direction:column;gap:4px;">';
    roots.forEach(function (root) {
        html += buildPickerNodeHtml(root, 0);
    });
    html += '</div>';
    pickerContainer.innerHTML = html;
}

window.togglePickerNode = function (nodeId) {
    expandedPickerNodes[nodeId] = !expandedPickerNodes[nodeId];
    renderPickerTree();
};

window.selectPickerCategory = function (categoryName) {
    selectedPickerCategory = categoryName;
    var catIdInput = document.getElementById('create-category-id');
    var catDisplay = document.getElementById('selectedCategoryDisplay');
    var catHidden = document.getElementById('create-category');
    var found = DB_CATEGORIES.find(function (c) { return c.categoryName === categoryName; });

    if (catDisplay) catDisplay.value = categoryName;
    if (catHidden) catHidden.value = categoryName;
    if (catIdInput && found) catIdInput.value = found.categoryId || '';

    renderPickerTree();
};

if (DB_CATEGORIES.length > 0) {
    renderPickerTree();
}

/* ─── Edit Modal — Category Tree Picker ──────────────────── */
var selectedEditPickerCategory = '';
var expandedEditPickerNodes = {};

function renderEditPickerTree() {
    var pickerContainer = document.getElementById('editCategoryTreePicker');
    if (!pickerContainer) return;

    var roots = DB_CATEGORIES.filter(function (c) {
        return c.parentId === null || c.parentId === 0 || c.parentId === 'null';
    });

    if (roots.length === 0) {
        pickerContainer.innerHTML = '<div style="color:rgba(16,55,92,0.4);text-align:center;padding:24px;">Chưa có danh mục nào.</div>';
        return;
    }

    function buildPickerNodeHtml(node, level) {
        var children = DB_CATEGORIES.filter(function (c) { return c.parentId === node.categoryId; });
        var hasChildren = children.length > 0;

        if (expandedEditPickerNodes[node.categoryId] === undefined) {
            expandedEditPickerNodes[node.categoryId] = true;
        }
        var isExpanded = expandedEditPickerNodes[node.categoryId];
        var isSelected = selectedEditPickerCategory === node.categoryName;
        var indent = level * 16;

        var html = '<div class="tree-node-wrapper">';
        html += '<div class="tree-node' + (isSelected ? ' selected' : '') + '"'
            + ' onclick="window.selectEditPickerCategory(decodeURIComponent(\'' + encodeURIComponent(node.categoryName) + '\'))"'
            + ' style="padding-left:' + indent + 'px">';

        if (hasChildren) {
            html += '<span class="tree-expand-btn"'
                + ' onclick="event.stopPropagation();window.toggleEditPickerNode(' + node.categoryId + ')">'
                + '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"'
                + ' style="transform:rotate(' + (isExpanded ? '90deg' : '0deg') + ');transition:transform 0.15s">'
                + '<polyline points="9 18 15 12 9 6"/></svg></span>';
        } else {
            html += '<span class="tree-leaf-spacer"></span>';
        }

        html += '<span class="tree-node-label">' + escapeHtml(node.categoryName) + '</span>';
        html += '</div>';

        if (hasChildren && isExpanded) {
            html += '<div class="tree-children">';
            children.forEach(function (child) {
                html += buildPickerNodeHtml(child, level + 1);
            });
            html += '</div>';
        }

        html += '</div>';
        return html;
    }

    var html = '<div style="display:flex;flex-direction:column;gap:4px;">';
    roots.forEach(function (root) {
        html += buildPickerNodeHtml(root, 0);
    });
    html += '</div>';
    pickerContainer.innerHTML = html;
}

window.toggleEditPickerNode = function (nodeId) {
    expandedEditPickerNodes[nodeId] = !expandedEditPickerNodes[nodeId];
    renderEditPickerTree();
};

window.selectEditPickerCategory = function (categoryName) {
    selectedEditPickerCategory = categoryName;
    var catDisplay = document.getElementById('selectedEditCategoryDisplay');
    var catHidden = document.getElementById('edit-category');
    if (catDisplay) catDisplay.value = categoryName;
    if (catHidden) catHidden.value = categoryName;

    renderEditPickerTree();
};

/* Edit Modal DOM Elements & Handlers */
var editOverlay   = document.getElementById('editModalOverlay');
var btnEditClose  = document.getElementById('editModalClose');
var btnEditCancel = document.getElementById('editModalCancel');
var btnEditSubmit = document.getElementById('btnEditSKUSubmit');

var editIdInput     = document.getElementById('edit-id');
var editNameInput   = document.getElementById('edit-name');
var editDimLengthInput = document.getElementById('edit-dim-length');
var editDimWidthInput  = document.getElementById('edit-dim-width');
var editDimHeightInput = document.getElementById('edit-dim-height');
var editWgtInput    = document.getElementById('edit-weight');
var editCodeLabel   = document.getElementById('edit-sku-code-label');
var editBarcodeInput = document.getElementById('edit-barcode');
var editUnitInput   = document.getElementById('edit-unit');
var editCategoryInput = document.getElementById('edit-category');

[btnEditClose, btnEditCancel].forEach(function (btn) {
    if (btn) {
        btn.addEventListener('click', function () {
            editOverlay.classList.remove('active');
        });
    }
});

editOverlay.addEventListener('click', function (e) {
    if (e.target === editOverlay) {
        editOverlay.classList.remove('active');
    }
});

window.triggerEditSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (!item) return;

    editIdInput.value = item.productId || item.id.substring(2);
    editCodeLabel.textContent = item.sku;
    editNameInput.value = item.name;

    // Parse dimensions
    var len = '', wid = '', hgt = '';
    if (item.dimensions && item.dimensions !== 'N/A') {
        var dimParts = item.dimensions.split(/[×x]/);
        if (dimParts.length === 3) {
            len = parseFloat(dimParts[0]) || '';
            wid = parseFloat(dimParts[1]) || '';
            hgt = parseFloat(dimParts[2]) || '';
        }
    }
    editDimLengthInput.value = len;
    editDimWidthInput.value = wid;
    editDimHeightInput.value = hgt;

    var wVal = '';
    if (item.weight && item.weight !== 'N/A') {
        wVal = parseFloat(item.weight.replace(' kg', '')) || '';
    }
    editWgtInput.value = wVal;
    editBarcodeInput.value = item.barcode || '';
    editUnitInput.value = item.unit || '';

    window.selectEditPickerCategory(item.category || '');

    editOverlay.classList.add('active');
};

window.triggerDeleteSKU = function (id) {
    var item = skus.find(function (s) { return s.id === id; });
    if (!item) return;

    if (confirm('Bạn có chắc chắn muốn xóa SKU "' + item.sku + '"?')) {
        if (id.indexOf('p-') === 0) {
            var productId = id.substring(2);
            submitPostAction('delete', { productId: productId });
        }
    }
};

if (btnEditSubmit) {
    btnEditSubmit.addEventListener('click', function () {
        var productId = editIdInput.value;
        var nameVal = editNameInput.value.trim();
        
        if (!nameVal) {
            alert('Tên sản phẩm không được bỏ trống!');
            return;
        }

        var lVal = editDimLengthInput.value.trim();
        var wVal = editDimWidthInput.value.trim();
        var hVal = editDimHeightInput.value.trim();
        
        var dimensionsVal = 'N/A';
        if (lVal || wVal || hVal) {
            var l = parseFloat(lVal) || 0;
            var w = parseFloat(wVal) || 0;
            var h = parseFloat(hVal) || 0;
            if (l <= 0 || w <= 0 || h <= 0) {
                alert('Kích thước Dài, Rộng, Cao phải là số thực dương!');
                return;
            }
            dimensionsVal = l + '×' + w + '×' + h;
        }
        
        var wgtVal = editWgtInput.value.trim();
        var weightVal = '0';
        if (wgtVal) {
            var wgt = parseFloat(wgtVal) || 0;
            if (wgt <= 0) {
                alert('Khối lượng phải là số thực dương!');
                return;
            }
            weightVal = wgt.toString();
        }

        var catName = editCategoryInput.value ? editCategoryInput.value.trim() : '';
        var catId = '';
        if (catName) {
            var found = DB_CATEGORIES.find(function (c) { return c.categoryName === catName; });
            if (found) catId = found.categoryId;
        }

        submitPostAction('update', {
            productId: productId,
            productName: nameVal,
            categoryId: catId,
            dimensions: dimensionsVal,
            weight: weightVal,
            barcode: editBarcodeInput.value.trim(),
            unit: editUnitInput.value.trim()
        });
    });
}

/* ─── Create Modal DOM Elements & Handlers ─────────────────── */
var createOverlay = document.getElementById('createModalOverlay');
var btnCreateTrigger = document.getElementById('btnCreateSKUTrigger');
var btnCreateClose   = document.getElementById('createModalClose');
var btnCreateCancel  = document.getElementById('createModalCancel');
var btnCreateSubmit  = document.getElementById('btnCreateSKUSubmit');

var createSkuInput  = document.getElementById('create-sku');
var createNameInput = document.getElementById('create-name');
var createCatInput  = document.getElementById('create-category');
var createDimLengthInput = document.getElementById('create-dim-length');
var createDimWidthInput  = document.getElementById('create-dim-width');
var createDimHeightInput = document.getElementById('create-dim-height');
var createWgtInput  = document.getElementById('create-weight');

if (btnCreateTrigger) {
    btnCreateTrigger.addEventListener('click', function () {
        if (DB_CATEGORIES.length > 0 && !selectedPickerCategory) {
            window.selectPickerCategory(DB_CATEGORIES[0].categoryName);
        }
        createOverlay.classList.add('active');
    });
}

[btnCreateClose, btnCreateCancel].forEach(function (btn) {
    if (btn) {
        btn.addEventListener('click', function () {
            createOverlay.classList.remove('active');
            clearCreateForm();
        });
    }
});

createOverlay.addEventListener('click', function (e) {
    if (e.target === createOverlay) {
        createOverlay.classList.remove('active');
        clearCreateForm();
    }
});

/* Auto Generate SKU */
var btnAutoGen = document.getElementById('btnAutoGenSku');
if (btnAutoGen) {
    btnAutoGen.addEventListener('click', function () {
        var catIdInput = document.getElementById('create-category-id');
        var catId = catIdInput ? catIdInput.value : '';
        if (!catId) {
            alert('Vui lòng chọn danh mục trước!');
            return;
        }
        btnAutoGen.disabled = true;
        btnAutoGen.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="animation:spin 0.8s linear infinite"><path d="M21 12a9 9 0 1 1-6.219-8.56"/></svg> Đang tạo...';
        fetch('${pageContext.request.contextPath}/business/sku/generate?categoryId=' + catId)
            .then(function(resp) { return resp.json(); })
            .then(function(data) {
                if (data.sku) {
                    createSkuInput.value = data.sku;
                    createSkuInput.removeAttribute('readonly');
                    createSkuInput.style.background = '#fff';
                    createSkuInput.style.cursor = 'text';
                    createSkuInput.style.color = '#059669';
                    createSkuInput.style.fontWeight = '700';
                    setTimeout(function() {
                        createSkuInput.style.color = '';
                        createSkuInput.style.fontWeight = '';
                    }, 2000);
                } else {
                    alert('Lỗi: ' + (data.error || 'Không thể tạo SKU tự động.'));
                }
            })
            .catch(function() {
                alert('Lỗi mạng khi tạo SKU tự động.');
            })
            .finally(function() {
                btnAutoGen.disabled = false;
                btnAutoGen.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/><polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/><line x1="4" y1="4" x2="9" y2="9"/></svg> Auto';
            });
    });
}

/* Create Submit */
if (btnCreateSubmit) {
    btnCreateSubmit.addEventListener('click', function () {
        var skuVal  = createSkuInput.value.trim();
        var nameVal = createNameInput.value.trim();

        if (!skuVal || !nameVal) {
            alert('Vui lòng nhập đầy đủ Mã SKU và Tên sản phẩm!');
            return;
        }

        var lVal = createDimLengthInput.value.trim();
        var wVal = createDimWidthInput.value.trim();
        var hVal = createDimHeightInput.value.trim();

        var dimensionsVal = 'N/A';
        if (lVal || wVal || hVal) {
            var l = parseFloat(lVal) || 0;
            var w = parseFloat(wVal) || 0;
            var h = parseFloat(hVal) || 0;
            if (l <= 0 || w <= 0 || h <= 0) {
                alert('Kích thước Dài, Rộng, Cao phải là số thực dương!');
            return;
            }
            dimensionsVal = l + '×' + w + '×' + h;
        }

        var wgtVal = createWgtInput.value.trim();
        var weightVal = '0';
        if (wgtVal) {
            var wgt = parseFloat(wgtVal) || 0;
            if (wgt <= 0) {
                alert('Khối lượng phải là số thực dương!');
                return;
            }
            weightVal = wgt.toString();
        }

        submitPostAction('create', {
            skuCode: skuVal,
            productName: nameVal,
            categoryName: createCatInput.value ? createCatInput.value.trim() : '',
            dimensions: dimensionsVal,
            weight: weightVal
        });
    });
}

function clearCreateForm() {
    if (!createSkuInput) return;
    createSkuInput.value = '';
    createSkuInput.setAttribute('readonly', 'true');
    createSkuInput.style.background = 'rgba(16, 55, 92, 0.03)';
    createSkuInput.style.cursor = 'not-allowed';
    createNameInput.value = '';
    if (DB_CATEGORIES.length > 0) {
        window.selectPickerCategory(DB_CATEGORIES[0].categoryName);
    } else {
        window.selectPickerCategory('');
    }
    createDimLengthInput.value = '';
    createDimWidthInput.value  = '';
    createDimHeightInput.value = '';
    createWgtInput.value  = '';
}

function padZero(n) { return n < 10 ? '0' + n : n; }

/* ─── Handlers ───────────────────────────────────────────── */
if (searchInput) {
    searchInput.addEventListener('input', function (e) {
        search = e.target.value;
        renderAll();
    });
}
if (catSelect) {
    catSelect.addEventListener('change', function (e) {
        selectedCategory = e.target.value;
        renderAll();
    });
}

window.setSKUTab = function (tabId) {
    activeTab = tabId;
    var btn = document.getElementById('tab-all');
    if (btn) {
        btn.classList.toggle('active', tabId === 'all');
    }
    renderAll();
};

/* CSV Export */
var btnExportCSV = document.getElementById('btnExportCSV');
if (btnExportCSV) {
    btnExportCSV.addEventListener('click', function () {
        var filteredList = getFilteredList();
        var headers = ["Mã SKU", "Tên sản phẩm", "Danh mục", "Khối lượng", "Kích thước", "Tồn kho", "Cấu hình kho", "Tạo bởi", "Cập nhật"];
        var csvContent = "\uFEFF" + headers.join(",") + "\n";
        
        filteredList.forEach(function (item) {
            var locs = item.locationConfigs && item.locationConfigs.length > 0
                ? item.locationConfigs.map(function(c) {
                    var loc = LOCATIONS.find(function(l) { return l.id === c.locationId; });
                    var zone = ZONES.find(function(z) { return z.id === c.zoneId; });
                    return (loc ? loc.code : '?') + " -> " + (zone ? zone.name : '?');
                  }).join(" | ")
                : "Chưa gán vị trí";
            
            var row = [
                '"' + item.sku.replace(/"/g, '""') + '"',
                '"' + item.name.replace(/"/g, '""') + '"',
                '"' + item.category.replace(/"/g, '""') + '"',
                '"' + item.weight.replace(/"/g, '""') + '"',
                '"' + item.dimensions.replace(/"/g, '""') + '"',
                item.qtyOnHand,
                '"' + locs.replace(/"/g, '""') + '"',
                '"' + (item.createdBy || '').replace(/"/g, '""') + '"',
                '"' + (item.lastUpdated || '').replace(/"/g, '""') + '"'
            ];
            csvContent += row.join(",") + "\n";
        });
        
        var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        var link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.setAttribute("download", "master_sku_" + new Date().toISOString().slice(0, 10) + ".csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    });
}

/* ─── Helpers ─── */

function getFilteredList() {
    return skus.filter(function (s) {
        var matchSearch = s.sku.toLowerCase().indexOf(search.toLowerCase()) > -1 || 
                          s.name.toLowerCase().indexOf(search.toLowerCase()) > -1;
        var matchCat    = selectedCategory === 'Tất cả' || s.category === selectedCategory;
        return matchSearch && matchCat;
    });
}

function updateTabBadges() {
    var b = document.getElementById('badge-all');
    if (b) b.textContent = skus.length;
}

/* ══ RENDER TABLE ══════════════════════════════════════════ */
function renderAll() {
    updateTabBadges();
    
    var filtered = getFilteredList();

    tableInfo.textContent = 'Hiển thị ' + filtered.length + ' / ' + skus.length + ' SKU';

    if (filtered.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:48px;color:rgba(16, 55, 92, 0.4)">Không tìm thấy sản phẩm SKU nào.</td></tr>';
        return;
    }

    var html = filtered.map(function (item, idx) {
        var isLowStock = item.qtyOnHand < item.minStock;
        var qtyTextClass = isLowStock ? 'stock-qty low-stock' : 'stock-qty normal-stock';

        var specHtml = '<div class="detail-icon-wrap">' +
            '<div class="detail-icon-row">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 3v18M12 3L7 8m5-5 5 5"/></svg>' + item.weight +
            '</div>' +
            '<div class="detail-icon-row">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg>' + item.dimensions +
            '</div>' +
        '</div>';

        var stockHtml = '<div class="stock-val-wrap">';
        if (isLowStock) {
            stockHtml += '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        }
        stockHtml += '<span class="' + qtyTextClass + '">' + item.qtyOnHand.toLocaleString() + '</span></div>';

        var locHtml = '';
        if (!item.locationConfigs || item.locationConfigs.length === 0) {
            locHtml = '<span class="loc-unassigned">' +
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>' +
                'Chưa gán vị trí</span>';
        } else {
            locHtml = '<div class="loc-tag-wrap">' +
                item.locationConfigs.map(function (c) {
                    var loc = LOCATIONS.find(function(l) { return l.id === c.locationId; });
                    var zone = ZONES.find(function(z) { return z.id === c.zoneId; });
                    return '<div class="loc-tag">' +
                           '<span class="loc-tag-code">' + (loc ? loc.code : '?') + '</span>' +
                           '<span style="color: rgba(16, 55, 92, 0.3); margin: 0 6px;">→</span>' +
                           '<span>' + (zone ? zone.name : '?') + '</span>' +
                           '</div>';
                }).join('') +
                '</div>';
        }

        var infoHtml = '<div class="info-lbl"><span class="info-lbl-inner">Tạo:</span> ' + item.createdBy + '</div>' +
                       '<div class="info-time">' + item.createdAt + '</div>';

        var editBtnHtml = '<button class="btn-act-circle edit" onclick="window.triggerEditSKU(\'' + item.id + '\')" title="Sửa">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>' +
            '</button>';
        var deleteBtnHtml = '<button class="btn-act-circle del" onclick="window.triggerDeleteSKU(\'' + item.id + '\')" title="Xóa">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>' +
            '</button>';

        var rowClass = idx % 2 === 0 ? '' : 'style="background:rgba(240, 244, 250, 0.25)"';

        return '<tr ' + rowClass + '>' +
            '<td><span class="sku-code-cell">' + item.sku + '</span></td>' +
            '<td><div class="sku-name-cell" title="' + item.name + '">' + item.name + '</div></td>' +
            '<td><span class="sku-cat-cell">' + item.category + '</span></td>' +
            '<td>' + specHtml + '</td>' +
            '<td>' + stockHtml + '</td>' +
            '<td>' + locHtml + '</td>' +
            '<td>' + infoHtml + '</td>' +
            '<td>' +
                '<div style="display:flex;align-items:center;justify-content:center;gap:8px">' +
                    editBtnHtml +
                    deleteBtnHtml +
                '</div>' +
            '</td>' +
        '</tr>';
    }).join('');

    tableBody.innerHTML = html;
}

/* ─── Bootstrap ─── */
renderAll();

})();
</script>
