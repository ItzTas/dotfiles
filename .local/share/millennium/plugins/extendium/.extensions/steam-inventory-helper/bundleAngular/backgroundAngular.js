(function () {
    'use strict';

    /******************************************************************************
    Copyright (c) Microsoft Corporation.

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
    OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
    ***************************************************************************** */

    function __awaiter(thisArg, _arguments, P, generator) {
        function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
        return new (P || (P = Promise))(function (resolve, reject) {
            function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
            function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
            function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
            step((generator = generator.apply(thisArg, _arguments || [])).next());
        });
    }

    function __classPrivateFieldGet(receiver, state, kind, f) {
        if (kind === "a" && !f) throw new TypeError("Private accessor was defined without a getter");
        if (typeof state === "function" ? receiver !== state || !f : !state.has(receiver)) throw new TypeError("Cannot read private member from an object whose class did not declare it");
        return kind === "m" ? f : kind === "a" ? f.call(receiver) : f ? f.value : state.get(receiver);
    }

    typeof SuppressedError === "function" ? SuppressedError : function (error, suppressed, message) {
        var e = new Error(message);
        return e.name = "SuppressedError", e.error = error, e.suppressed = suppressed, e;
    };

    /// <reference types="chrome"/>
    var _Utils_instances, _Utils_configureBodyRequest, _Utils_buildGetRequestUrl, _Utils_handleResponse, _Utils_handleError, _Utils_convertObjectToFormUrlEncoded;
    const htmlRegExp = /((<![^>]+>)|(^<div))/i;
    class Utils {
        constructor() {
            _Utils_instances.add(this);
            /**
             * Handles the fetch response, parsing JSON or text based on the Content-Type.
             *
             * @param {Response} response - The fetch response object.
             * @returns {Promise<any>} A promise that resolves with the parsed response data.
             * @throws {Response} If the response is not ok (status code not in the 200-299 range).
             */
            _Utils_handleResponse.set(this, (response) => __awaiter(this, void 0, void 0, function* () {
                var _a;
                const cloneResponse = response.clone();
                if (!response.ok)
                    throw response;
                if ((_a = response.headers.get('Content-Type')) === null || _a === void 0 ? void 0 : _a.includes('application/json')) {
                    return response.json();
                }
                else {
                    const cloneText = yield cloneResponse.text();
                    const isHtml = htmlRegExp.test(cloneText.trim());
                    if (!isHtml) {
                        return JSON.parse(cloneText);
                    }
                    else {
                        return response.text();
                    }
                }
            }));
            /**
             * Handles fetch errors, logging the error and adding response data to the error object if available.
             *
             * @param {any} error - The error object.
             * @returns {Promise<void>} A promise that rejects with the enhanced error object.
             * @throws {any} The enhanced error object.
             */
            _Utils_handleError.set(this, (error) => __awaiter(this, void 0, void 0, function* () {
                var _a;
                console.error('Fetch error:', error);
                if (error instanceof Response) {
                    try {
                        if ((_a = error.headers.get('Content-Type')) === null || _a === void 0 ? void 0 : _a.includes('application/json')) {
                            const json = yield error.json();
                            if (!json)
                                throw error;
                            error.responseJSON = json;
                            error.responseText = JSON.stringify(json);
                        }
                        else {
                            const cloneError = error.clone();
                            const errorText = yield cloneError.text();
                            if (!errorText)
                                throw error;
                            const isHtml = /<\/?[a-z][\s\S]*>/i.test(errorText);
                            if (!isHtml) {
                                error.responseJSON = JSON.parse(errorText);
                                error.responseText = errorText;
                            }
                            else {
                                error.responseText = errorText;
                            }
                        }
                    }
                    catch (err) {
                        console.error('Error while handling the fetch error:', err);
                        throw error;
                    }
                    throw error;
                }
                else {
                    if (/Maximum call stack size exceeded/i.test(error === null || error === void 0 ? void 0 : error.message)) {
                        chrome.runtime.reload();
                    }
                    throw error;
                }
            }));
        }
        /**
         * Makes an API request using fetch.
         *
         * @param {Object} params - The request parameters.
         * @param {string} [params.method='GET'] - The HTTP method (GET, POST, PUT, DELETE, etc.).
         * @param {any} [params.data] - The request body data.
         * @param {string} params.url - The request URL.
         * @param {Record<string, string>} [params.headers={}] - The request headers.
         * @param {AbortSignal} [params.signal] - An AbortSignal to cancel the request.
         * @returns {Promise<any>} A promise that resolves with the response data or rejects with an error.
         */
        apiRequest(params) {
            return __awaiter(this, void 0, void 0, function* () {
                const { method = 'GET', data, url, headers = {}, signal } = params;
                const requestOptions = {
                    method,
                    headers,
                    signal,
                };
                let processedData = data;
                let requestUrl = url;
                if (['POST', 'PUT'].includes(method.toUpperCase())) {
                    __classPrivateFieldGet(this, _Utils_instances, "m", _Utils_configureBodyRequest).call(this, requestOptions, processedData, headers);
                }
                else if (data && Object.keys(data).length) {
                    requestUrl = __classPrivateFieldGet(this, _Utils_instances, "m", _Utils_buildGetRequestUrl).call(this, url, processedData);
                }
                requestOptions.headers = headers;
                return fetch(requestUrl, requestOptions).then(__classPrivateFieldGet(this, _Utils_handleResponse, "f")).catch(__classPrivateFieldGet(this, _Utils_handleError, "f"));
            });
        }
    }
    _Utils_handleResponse = new WeakMap(), _Utils_handleError = new WeakMap(), _Utils_instances = new WeakSet(), _Utils_configureBodyRequest = function _Utils_configureBodyRequest(requestOptions, data, headers) {
        let processedData = data;
        const contentType = Object.keys(headers).find((headerKey) => headerKey.toLowerCase() === 'content-type');
        if (!contentType) {
            headers['Content-Type'] = 'application/json';
            processedData = JSON.stringify(data);
        }
        else {
            const isFormUrlencoded = headers[contentType].includes('application/x-www-form-urlencoded');
            if (isFormUrlencoded) {
                processedData = __classPrivateFieldGet(this, _Utils_instances, "m", _Utils_convertObjectToFormUrlEncoded).call(this, data);
            }
        }
        requestOptions.body = processedData;
    }, _Utils_buildGetRequestUrl = function _Utils_buildGetRequestUrl(url, data) {
        let getParams = '';
        for (const [key, value] of Object.entries(data)) {
            getParams += `${getParams ? `&${key}=${encodeURIComponent(value)}` : `${key}=${encodeURIComponent(value)}`}`;
        }
        return `${url}${getParams ? `?${getParams}` : ''}`;
    }, _Utils_convertObjectToFormUrlEncoded = function _Utils_convertObjectToFormUrlEncoded(data) {
        const query = new URLSearchParams();
        const buildQuery = (obj, prefix = '') => {
            for (const [key, value] of Object.entries(obj)) {
                const prefixedKey = prefix ? `${prefix}[${key}]` : key;
                if (typeof value === 'object' && !Array.isArray(value)) {
                    buildQuery(value, prefixedKey);
                }
                else if (Array.isArray(value)) {
                    value.forEach((val) => query.append(`${prefixedKey}[]`, val));
                }
                else {
                    if (typeof value === 'string') {
                        query.append(prefixedKey, value);
                    }
                }
            }
        };
        buildQuery(data);
        return query.toString();
    };
    var Utils$1 = new Utils();

    class KeysMapper {
        getKeyOffersSiteToApiMapper(params) {
            var _a, _b, _c, _d, _e, _f;
            const backendParams = {};
            if (params.appType)
                backendParams['appType'] = params.appType;
            if (params.searchQuery)
                backendParams['searchQuery'] = params.searchQuery;
            if ((_a = params.regions) === null || _a === void 0 ? void 0 : _a.length)
                backendParams['regions'] = params.regions;
            if ((_b = params.langs) === null || _b === void 0 ? void 0 : _b.length)
                backendParams['langs'] = params.langs;
            if ((_c = params.genres) === null || _c === void 0 ? void 0 : _c.length)
                backendParams['genres'] = params.genres;
            if ((_d = params.categories) === null || _d === void 0 ? void 0 : _d.length)
                backendParams['categories'] = params.categories;
            if ((_e = params.platforms) === null || _e === void 0 ? void 0 : _e.length)
                backendParams['platforms'] = params.platforms;
            if (params.priceMin != null)
                backendParams['priceMin'] = params.priceMin * 1000;
            if (params.priceMax != null)
                backendParams['priceMax'] = params.priceMax * 1000;
            if (params.steamMin != null)
                backendParams['steamMin'] = params.steamMin * 1000;
            if (params.steamMax != null)
                backendParams['steamMax'] = params.steamMax * 1000;
            if (params.cheaperSteam != null)
                backendParams['cheaperSteam'] = params.cheaperSteam;
            if (params.sortBy)
                backendParams['sortBy'] = params.sortBy;
            if (params.page != null)
                backendParams['page'] = params.page;
            if (params.limit != null)
                backendParams['limit'] = params.limit;
            if ((_f = params.appId) === null || _f === void 0 ? void 0 : _f.length)
                backendParams['appIds'] = params.appId;
            if (params.currency)
                backendParams['currency'] = params.currency;
            return backendParams;
        }
        getKeyOffersApiToSiteMapper(apiData) {
            var _a;
            const itemsArray = Array.isArray((_a = apiData.f) === null || _a === void 0 ? void 0 : _a.a) ? apiData.f.a : [];
            return {
                data: apiData.f
                    ? {
                        currentPage: apiData.f.c,
                        hasMore: apiData.f.b,
                        nextPage: apiData.f.d,
                        totalElements: apiData.f.e,
                        items: itemsArray.map((item) => ({
                            appId: item.c,
                            header: item.e,
                            price: item.f,
                            steamPrice: item.g,
                            title: item.d,
                            offerId: item.b,
                            regions: item.l,
                            platform: item.m,
                        })),
                    }
                    : null,
                success: apiData.e,
                timestamp: apiData.g,
            };
        }
        getKeyOffersMetaApiToSiteMapper(apiData) {
            const siteData = {
                prices: {
                    min: apiData.a.a / 1000,
                    max: apiData.a.b / 1000,
                    steamMin: apiData.a.c / 1000,
                    steamMax: apiData.a.d / 1000,
                },
            };
            return siteData;
        }
    }
    var KeysMapper$1 = new KeysMapper();

    var _KeysService_apiUrlV2;
    class KeysService {
        constructor() {
            _KeysService_apiUrlV2.set(this, 'https://gamestats.steaminventoryhelper.com/api/v2/');
        }
        getKeyOffers(params) {
            return __awaiter(this, void 0, void 0, function* () {
                try {
                    const mappedParams = KeysMapper$1.getKeyOffersSiteToApiMapper(params);
                    const queryParams = new URLSearchParams();
                    //TODO вынести это в какой-то utils
                    Object.entries(mappedParams).forEach(([key, value]) => {
                        if (value === undefined || value === null)
                            return;
                        if (Array.isArray(value)) {
                            if (value.length === 0)
                                return;
                            queryParams.set(key, value.join(','));
                        }
                        else {
                            queryParams.set(key, String(value));
                        }
                    });
                    const response = yield Utils$1.apiRequest({
                        url: `${__classPrivateFieldGet(this, _KeysService_apiUrlV2, "f")}key-offers?m=1&${queryParams.toString()}`,
                    });
                    return KeysMapper$1.getKeyOffersApiToSiteMapper(response);
                }
                catch (e) {
                    return { success: false, error: e.message || e.responseJSON || 'Error, something went wrong' };
                }
            });
        }
        getMeta() {
            return __awaiter(this, void 0, void 0, function* () {
                try {
                    const response = yield Utils$1.apiRequest({
                        url: `${__classPrivateFieldGet(this, _KeysService_apiUrlV2, "f")}key-offers/meta?m=1`,
                    });
                    if (response.e && response.f) {
                        const mappedData = KeysMapper$1.getKeyOffersMetaApiToSiteMapper(response.f);
                        return {
                            success: response.e,
                            data: mappedData,
                        };
                    }
                    else {
                        throw new Error(`Unable to get meta data`);
                    }
                }
                catch (e) {
                    return { success: false, error: e.message || e.responseJSON || 'Error, something went wrong' };
                }
            });
        }
    }
    _KeysService_apiUrlV2 = new WeakMap();
    var KeysService$1 = new KeysService();

    var KeysController = {
        msg: {
            getKeyOffers: {
                code: 'TS_GET_KEY_OFFERS',
                handler: (data, cb) => __awaiter(void 0, void 0, void 0, function* () {
                    try {
                        const response = yield KeysService$1.getKeyOffers(data);
                        cb(response);
                    }
                    catch (e) {
                        cb({ success: false, error: e.message || e.responseJSON || 'Error, something went wrong' });
                    }
                }),
            },
            getMeta: {
                code: 'TS_GET_KEY_OFFERS_METADATA',
                handler: (cb) => __awaiter(void 0, void 0, void 0, function* () {
                    try {
                        const response = yield KeysService$1.getMeta();
                        cb(response);
                    }
                    catch (e) {
                        cb({ success: false, error: e.message || e.responseJSON || 'Error, something went wrong' });
                    }
                }),
            },
        },
    };

    const msgListenerHandler$1 = (request, sender, sendResponse) => __awaiter(void 0, void 0, void 0, function* () {
        switch (request.type) {
            case KeysController.msg.getKeyOffers.code:
                KeysController.msg.getKeyOffers.handler(request.data, sendResponse);
                break;
            case KeysController.msg.getMeta.code:
                KeysController.msg.getMeta.handler(sendResponse);
                break;
        }
        return true;
    });
    const msgListenerInitHandler$1 = () => __awaiter(void 0, void 0, void 0, function* () {
        chrome.runtime.onMessage.addListener(msgListenerHandler$1);
        chrome.runtime.onMessageExternal.addListener(msgListenerHandler$1);
    });
    const alarmListenerHandler$1 = (alarm) => __awaiter(void 0, void 0, void 0, function* () {
        switch (alarm.name) {
                }
    });
    const alarmListenerInitHandler$1 = () => __awaiter(void 0, void 0, void 0, function* () {
        chrome.alarms.onAlarm.addListener(alarmListenerHandler$1);
    });
    var Keys = {
        msgListener: {
            listener: {
                handler: msgListenerHandler$1,
            },
            init: {
                handler: msgListenerInitHandler$1,
            },
        },
        alarmListener: {
            listener: {
                handler: alarmListenerHandler$1,
            },
            init: {
                handler: alarmListenerInitHandler$1,
            },
        },
    };

    const handleAlarms$1 = () => { };
    const handleMessages$1 = () => {
        Keys.msgListener.init.handler();
    };
    var KeysGlobalHandler = {
        initListener: {
            handler: () => {
                try {
                    handleAlarms$1();
                    handleMessages$1();
                }
                catch (e) {
                    console.log(e);
                }
            },
        },
    };

    const SIH_API_URL = 'https://api.steaminventoryhelper.com';

    /// <reference types="chrome"/>
    class Storage {
        get(params) {
            return new Promise((resolve, reject) => {
                chrome.storage.sync.get(params, (result) => {
                    if (chrome.runtime.lastError) {
                        reject(chrome.runtime.lastError);
                    }
                    else {
                        resolve(result);
                    }
                });
            });
        }
        set(params) {
            return new Promise((resolve, reject) => {
                chrome.storage.sync.set(params, () => {
                    if (chrome.runtime.lastError) {
                        reject(chrome.runtime.lastError);
                    }
                    else {
                        resolve();
                    }
                });
            });
        }
        setByName({ name, value }) {
            return this.set({ [name]: value });
        }
        getLocal(params) {
            return new Promise((resolve, reject) => {
                chrome.storage.local.get(params, (result) => {
                    if (chrome.runtime.lastError) {
                        reject(chrome.runtime.lastError);
                    }
                    else {
                        resolve(result);
                    }
                });
            });
        }
        setLocal(params) {
            return new Promise((resolve, reject) => {
                chrome.storage.local.set(params, () => {
                    if (chrome.runtime.lastError) {
                        reject(chrome.runtime.lastError);
                    }
                    else {
                        resolve();
                    }
                });
            });
        }
        setLocalByName({ name, value }) {
            return this.setLocal({ [name]: value });
        }
        clear(storage = 'sync') {
            if (storage === 'sync') {
                chrome.storage.sync.clear(() => { });
            }
            else {
                chrome.storage.local.clear(() => { });
            }
        }
    }
    var Storage$1 = new Storage();

    var _RatesUtils_instances, _RatesUtils_getNextNormalRateTime, _RatesUtils_getNextSteamRateTime;
    class RatesUtils {
        constructor() {
            _RatesUtils_instances.add(this);
            this.isNeedUpdateRates = (_a) => __awaiter(this, [_a], void 0, function* ({ base = 'USD', endPoint = 'rates', }) {
                var _b, _c;
                const storageKey = endPoint !== 'rates' ? 'cached_steam_rates' : 'cached_rates';
                const storage = (yield Storage$1.get(storageKey))[storageKey] || {};
                const updatedAt = (_c = (_b = storage === null || storage === void 0 ? void 0 : storage[base]) === null || _b === void 0 ? void 0 : _b.updatedAt) !== null && _c !== void 0 ? _c : 0;
                if (!updatedAt)
                    return true;
                const nextUpdateTime = endPoint === 'rates' ? __classPrivateFieldGet(this, _RatesUtils_instances, "m", _RatesUtils_getNextNormalRateTime).call(this, updatedAt) : __classPrivateFieldGet(this, _RatesUtils_instances, "m", _RatesUtils_getNextSteamRateTime).call(this, updatedAt);
                return Date.now() >= nextUpdateTime;
            });
            this.setRatesInCache = (_a) => __awaiter(this, [_a], void 0, function* ({ base, response, endPoint = 'rates', }) {
                if (!base || !(response === null || response === void 0 ? void 0 : response.success))
                    return;
                const storageKey = endPoint !== 'rates' ? 'cached_steam_rates' : 'cached_rates';
                const storage = (yield Storage$1.get(storageKey))[storageKey] || {};
                storage[base] = Object.assign(Object.assign({}, response), { updatedAt: Date.now() });
                yield Storage$1.set({ [storageKey]: storage });
            });
            this.getCachedRates = (_a) => __awaiter(this, [_a], void 0, function* ({ base = 'USD', endPoint = 'rates', }) {
                const storageKey = endPoint !== 'rates' ? 'cached_steam_rates' : 'cached_rates';
                const storage = (yield Storage$1.get(storageKey))[storageKey] || {};
                return storage === null || storage === void 0 ? void 0 : storage[base];
            });
        }
        // TODO: REFACTOR THIS
        getConvertRates(rates) {
            const amount = [1, 100, 1000, 10000];
            const base = rates.data.base;
            const convertCurrencyRates = {
                base,
                ts: rates.data.ts,
                rates: {},
            };
            for (const strCode in rates.data.rates) {
                if (strCode !== base) {
                    let number = rates.data.rates[base] / rates.data.rates[strCode];
                    const numberString = number.toString();
                    let count = 0;
                    if (numberString[0] === '0') {
                        count = 1;
                        for (let i = 2; i < numberString.length; i++) {
                            if (numberString[i] === '0') {
                                count++;
                            }
                            else {
                                break;
                            }
                        }
                        if (count >= 1 && count <= 3) {
                            number *= amount[count];
                        }
                        else if (count > 3) {
                            number *= amount[3];
                        }
                    }
                    convertCurrencyRates.rates[strCode] = {
                        count: count < 3 ? amount[count] : amount[3],
                        number,
                    };
                }
                else {
                    convertCurrencyRates.rates[strCode] = {
                        count: 1,
                        number: rates.data.rates[base],
                    };
                }
            }
            return convertCurrencyRates;
        }
    }
    _RatesUtils_instances = new WeakSet(), _RatesUtils_getNextNormalRateTime = function _RatesUtils_getNextNormalRateTime(fromTime = Date.now()) {
        const date = new Date(fromTime);
        if (date.getHours() < 12) {
            date.setHours(12, 0, 0, 0); // сегодня в 12:00
        }
        else {
            date.setDate(date.getDate() + 1); // завтра
            date.setHours(0, 0, 0, 0); // в 00:00
        }
        date.setMinutes(date.getMinutes() + 5); // запас в 5 минут
        return date.getTime();
    }, _RatesUtils_getNextSteamRateTime = function _RatesUtils_getNextSteamRateTime(fromTime = Date.now()) {
        const validHours = [1, 5, 9, 13, 17, 21];
        const date = new Date(fromTime);
        for (const hour of validHours) {
            if (date.getHours() < hour || (date.getHours() === hour && date.getMinutes() < 1)) {
                date.setHours(hour, 1, 0, 0);
                date.setMinutes(date.getMinutes() + 5);
                return date.getTime();
            }
        }
        // если не нашли — следующий день в 01:01
        date.setDate(date.getDate() + 1);
        date.setHours(1, 1, 0, 0);
        date.setMinutes(date.getMinutes() + 5);
        return date.getTime();
    };
    var RatesUtils$1 = new RatesUtils();

    var _RatesService_getConvertRates;
    class RatesService {
        constructor() {
            _RatesService_getConvertRates.set(this, (rates) => {
                return new Promise((resolve) => {
                    const amount = [1, 100, 1000, 10000];
                    const { base, rates: ratesInfo } = rates.data;
                    const convertCurrencyRates = { base, rates: {}, ts: rates.data.ts };
                    Object.entries(ratesInfo).forEach(([strCode, rate]) => {
                        if (strCode === base) {
                            convertCurrencyRates.rates[strCode] = { count: 1, number: rate };
                            return;
                        }
                        const baseRate = ratesInfo[base];
                        let number = baseRate / rate;
                        // Count leading zeros after decimal point
                        const matchResult = number.toString().match(/^0\.0*/);
                        const leadingZeros = matchResult ? matchResult[0].length - 2 : 0;
                        // Apply multiplier based on number of leading zeros
                        if (leadingZeros > 0) {
                            const multiplier = amount[Math.min(leadingZeros, 3)];
                            number *= multiplier;
                        }
                        convertCurrencyRates.rates[strCode] = {
                            count: Math.min(leadingZeros, 3) > 0 ? amount[Math.min(leadingZeros, 3)] : 1,
                            number,
                        };
                    });
                    resolve(convertCurrencyRates);
                });
            });
        }
        setGlobalRates() {
            return __awaiter(this, void 0, void 0, function* () {
                try {
                    const { currency_code } = yield Storage$1.get('currency_code');
                    const { userInfo } = yield Storage$1.getLocal('userInfo');
                    const { steamCurrency = { strCode: 'USD' } } = !(userInfo === null || userInfo === void 0 ? void 0 : userInfo.authorization) || (yield Storage$1.get({ steamCurrency: { strCode: 'USD' } }));
                    const base = currency_code || steamCurrency.strCode;
                    const isNeedUpdateDefaultRates = yield RatesUtils$1.isNeedUpdateRates({});
                    const isNeedUpdateSelectedRates = yield RatesUtils$1.isNeedUpdateRates({ base });
                    const defaultRates = isNeedUpdateDefaultRates
                        ? yield this.fetchRates('USD')
                        : yield RatesUtils$1.getCachedRates({});
                    const selectedRates = isNeedUpdateSelectedRates
                        ? yield this.fetchRates(base)
                        : yield RatesUtils$1.getCachedRates({ base });
                    if (!(defaultRates === null || defaultRates === void 0 ? void 0 : defaultRates.success) || !(selectedRates === null || selectedRates === void 0 ? void 0 : selectedRates.success))
                        return;
                    if (isNeedUpdateDefaultRates) {
                        yield RatesUtils$1.setRatesInCache({
                            base: 'USD',
                            response: defaultRates,
                        });
                    }
                    if (isNeedUpdateSelectedRates) {
                        yield RatesUtils$1.setRatesInCache({
                            base,
                            response: selectedRates,
                        });
                    }
                    yield Storage$1.set({ default_currency_rates: defaultRates.data });
                    yield Storage$1.set({ currency_rates: selectedRates.data });
                    const convertCurrencyRates = RatesUtils$1.getConvertRates(selectedRates);
                    yield Storage$1.set({ global_currency_rates: convertCurrencyRates });
                }
                catch (error) {
                    console.error(error);
                }
            });
        }
        setSteamRates() {
            return __awaiter(this, void 0, void 0, function* () {
                try {
                    const { currency_code } = yield Storage$1.get('currency_code');
                    const { userInfo } = yield Storage$1.getLocal('userInfo');
                    const { steamCurrency = { strCode: 'USD' } } = !(userInfo === null || userInfo === void 0 ? void 0 : userInfo.authorization) || (yield Storage$1.get({ steamCurrency: { strCode: 'USD' } }));
                    const base = currency_code || steamCurrency.strCode;
                    const isNeedUpdateDefaultSteamRates = yield RatesUtils$1.isNeedUpdateRates({
                        endPoint: 'steam-rates',
                    });
                    const isNeedUpdateSelectedSteamRates = yield RatesUtils$1.isNeedUpdateRates({
                        base,
                        endPoint: 'steam-rates',
                    });
                    const defaultSteamRates = isNeedUpdateDefaultSteamRates
                        ? yield this.fetchRates('USD', 'steam-rates')
                        : yield RatesUtils$1.getCachedRates({ endPoint: 'steam-rates' });
                    const selectedSteamRates = isNeedUpdateSelectedSteamRates
                        ? yield this.fetchRates(base, 'steam-rates')
                        : yield RatesUtils$1.getCachedRates({ base, endPoint: 'steam-rates' });
                    if (!(defaultSteamRates === null || defaultSteamRates === void 0 ? void 0 : defaultSteamRates.success) || !(selectedSteamRates === null || selectedSteamRates === void 0 ? void 0 : selectedSteamRates.success))
                        return;
                    if (isNeedUpdateDefaultSteamRates) {
                        yield RatesUtils$1.setRatesInCache({
                            base: 'USD',
                            endPoint: 'steam-rates',
                            response: defaultSteamRates,
                        });
                    }
                    if (isNeedUpdateSelectedSteamRates) {
                        yield RatesUtils$1.setRatesInCache({
                            base,
                            endPoint: 'steam-rates',
                            response: selectedSteamRates,
                        });
                    }
                    yield Storage$1.set({ default_steam_rates: defaultSteamRates.data });
                    yield Storage$1.set({ steam_rates: selectedSteamRates.data });
                    const convertCurrencyRates = RatesUtils$1.getConvertRates(selectedSteamRates);
                    yield Storage$1.set({ steam_currency_rates: convertCurrencyRates });
                }
                catch (error) {
                    console.error(error);
                }
            });
        }
        fetchRates(base = 'USD', endPoint = 'rates') {
            return Utils$1.apiRequest({
                url: `${SIH_API_URL}/${endPoint}`,
                data: {
                    base,
                },
            });
        }
    }
    _RatesService_getConvertRates = new WeakMap();
    var RatesService$1 = new RatesService();

    var RatesController = {
        msg: {
            getExchangeRate: {
                code: 'exchangerate',
                handler: (cb) => __awaiter(void 0, void 0, void 0, function* () {
                    try {
                        const isNeedUpdateDefaultRates = yield RatesUtils$1.isNeedUpdateRates({});
                        const defaultRates = isNeedUpdateDefaultRates
                            ? yield RatesService$1.fetchRates()
                            : yield RatesUtils$1.getCachedRates({});
                        if (isNeedUpdateDefaultRates && defaultRates) {
                            yield RatesUtils$1.setRatesInCache({ base: 'USD', response: defaultRates });
                        }
                        cb(defaultRates);
                    }
                    catch (e) {
                        console.error(e);
                        cb({ success: false });
                    }
                }),
            },
            getRates: {
                code: 'GetRates',
                handler: (_a, cb_1) => __awaiter(void 0, [_a, cb_1], void 0, function* ({ base = 'USD' }, cb) {
                    try {
                        const isNeedUpdateSelectedRates = yield RatesUtils$1.isNeedUpdateRates({ base });
                        const defaultRates = isNeedUpdateSelectedRates
                            ? yield RatesService$1.fetchRates(base)
                            : yield RatesUtils$1.getCachedRates({ base });
                        if (isNeedUpdateSelectedRates && defaultRates) {
                            yield RatesUtils$1.setRatesInCache({ base, response: defaultRates });
                        }
                        cb(defaultRates);
                    }
                    catch (e) {
                        console.error(e);
                        cb({ success: false });
                    }
                }),
            },
        },
        alarm: {
            getGlobalRates: {
                code: 'BACKGROUND_ALARM_SET_EXCHANGE_RATES',
                handler: () => __awaiter(void 0, void 0, void 0, function* () {
                    try {
                        yield RatesService$1.setGlobalRates();
                    }
                    catch (e) {
                        console.log(e);
                    }
                }),
            },
            getSteamRates: {
                code: 'BACKGROUND_ALARM_SET_STEAM_RATES',
                handler: () => __awaiter(void 0, void 0, void 0, function* () {
                    try {
                        yield RatesService$1.setSteamRates();
                    }
                    catch (e) {
                        console.log(e);
                    }
                }),
            },
        },
    };

    const msgListenerHandler = (request, sender, sendResponse) => __awaiter(void 0, void 0, void 0, function* () {
        switch (request.type) {
            case RatesController.msg.getExchangeRate.code:
                RatesController.msg.getExchangeRate.handler(sendResponse);
                break;
            case RatesController.msg.getRates.code:
                RatesController.msg.getRates.handler(request.data || {}, sendResponse);
                break;
        }
        return true;
    });
    const msgListenerInitHandler = () => __awaiter(void 0, void 0, void 0, function* () {
        chrome.runtime.onMessage.addListener(msgListenerHandler);
        chrome.runtime.onMessageExternal.addListener(msgListenerHandler);
    });
    const createAlarms = () => {
        chrome.alarms.create('BACKGROUND_ALARM_SET_EXCHANGE_RATES', {
            delayInMinutes: 1,
            periodInMinutes: 10,
        });
        chrome.alarms.create('BACKGROUND_ALARM_SET_STEAM_RATES', {
            delayInMinutes: 1,
            periodInMinutes: 10,
        });
    };
    const alarmListenerHandler = (alarm) => __awaiter(void 0, void 0, void 0, function* () {
        switch (alarm.name) {
            case RatesController.alarm.getGlobalRates.code:
                yield RatesController.alarm.getGlobalRates.handler();
                break;
            case RatesController.alarm.getSteamRates.code:
                yield RatesController.alarm.getSteamRates.handler();
                break;
        }
    });
    const alarmListenerInitHandler = () => __awaiter(void 0, void 0, void 0, function* () {
        createAlarms();
        chrome.alarms.onAlarm.addListener(alarmListenerHandler);
    });
    var Rates = {
        msgListener: {
            listener: {
                handler: msgListenerHandler,
            },
            init: {
                handler: msgListenerInitHandler,
            },
        },
        alarmListener: {
            listener: {
                handler: alarmListenerHandler,
            },
            init: {
                handler: alarmListenerInitHandler,
            },
        },
    };

    const handleAlarms = () => {
        Rates.alarmListener.init.handler();
    };
    const handleMessages = () => {
        Rates.msgListener.init.handler();
    };
    var RatesGlobalHandler = {
        initListener: {
            handler: () => {
                try {
                    handleAlarms();
                    handleMessages();
                }
                catch (e) {
                    console.log(e);
                }
            },
        },
        initGlobalFunctions: {
            handler: () => {
                self.setGlobalRates = () => RatesService$1.setGlobalRates();
                self.setSteamRates = () => RatesService$1.setSteamRates();
            },
        },
    };

    /// <reference types="chrome"/>
    (() => {
        RatesGlobalHandler.initListener.handler();
        RatesGlobalHandler.initGlobalFunctions.handler();
        KeysGlobalHandler.initListener.handler();
    })();

})();
//# sourceMappingURL=backgroundAngular.js.map
