defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    bucket = start_supervised!(KV.Bucket)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "update value by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    KV.Bucket.put(bucket, "milk", 3)
    KV.Bucket.put(bucket, "milk", 7)
    assert KV.Bucket.get(bucket, "milk") == 7
  end

  test "remove value by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    assert KV.Bucket.get(bucket, "eggs") == nil
    KV.Bucket.put(bucket, "milk", 3)
    KV.Bucket.put(bucket, "eggs", 6)
    KV.Bucket.delete(bucket, "milk")
    assert KV.Bucket.get(bucket, "milk") == nil
    assert KV.Bucket.get(bucket, "eggs") == 6
  end

  test "buckets are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
