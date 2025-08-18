import React, { useEffect, useCallback, useRef } from 'react';
import { useAppDispatch, useAppSelector } from '../store/hooks';

interface UseDataFetchingOptions {
  fetchAction: any;
  selector: (state: any) => any;
  dependencies?: any[];
  autoFetch?: boolean;
  debounceMs?: number;
}

/**
 * データ取得の最適化用カスタムフック
 * デバウンス、キャッシュ、エラーハンドリングを統合
 */
export const useDataFetching = ({
  fetchAction,
  selector,
  dependencies = [],
  autoFetch = true,
  debounceMs = 300,
}: UseDataFetchingOptions) => {
  const dispatch = useAppDispatch();
  const data = useAppSelector(selector);
  const timeoutRef = useRef<NodeJS.Timeout | undefined>(undefined);
  const lastFetchRef = useRef<number>(0);

  const fetchData = useCallback(() => {
    const now = Date.now();
    if (now - lastFetchRef.current < debounceMs) {
      // デバウンス処理
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      timeoutRef.current = setTimeout(() => {
        dispatch(fetchAction());
        lastFetchRef.current = Date.now();
      }, debounceMs);
    } else {
      dispatch(fetchAction());
      lastFetchRef.current = now;
    }
  }, [dispatch, fetchAction, debounceMs]);

  const refetch = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    dispatch(fetchAction());
    lastFetchRef.current = Date.now();
  }, [dispatch, fetchAction]);

  useEffect(() => {
    if (autoFetch) {
      fetchData();
    }
  }, [autoFetch, fetchData, dependencies]);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return {
    data,
    loading: data.loading,
    error: data.error,
    fetchData,
    refetch,
  };
};

/**
 * 無限スクロール用のカスタムフック
 */
export const useInfiniteScroll = (
  callback: () => void,
  hasMore: boolean,
  loading: boolean
) => {
  const observerRef = useRef<IntersectionObserver | undefined>(undefined);

  const lastElementRef = useCallback(
    (node: HTMLElement | null) => {
      if (loading) return;
      
      if (observerRef.current) {
        observerRef.current.disconnect();
      }

      observerRef.current = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting && hasMore) {
          callback();
        }
      });

      if (node) {
        observerRef.current.observe(node);
      }
    },
    [loading, hasMore, callback]
  );

  useEffect(() => {
    return () => {
      if (observerRef.current) {
        observerRef.current.disconnect();
      }
    };
  }, []);

  return lastElementRef;
};

/**
 * ローカルストレージ用のカスタムフック
 */
export const useLocalStorage = <T>(key: string, initialValue: T) => {
  const [storedValue, setStoredValue] = React.useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue] as const;
}; 