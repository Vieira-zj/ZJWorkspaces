package zj_test

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	newtime "qbox.us/cc/time"
	"qbox.us/sstore"

	"qiniu.com/qtest/biz/bucket/domain"
	"qiniu.com/qtest/biz/bucket/tblmgr"
	"qiniu.com/qtest/biz/bucket/uc"
	"qiniu.com/qtest/biz/ebd"
	"qiniu.com/qtest/biz/io"
	"qiniu.com/qtest/biz/kmq"
	"qiniu.com/qtest/biz/pfd"
	"qiniu.com/qtest/biz/qiniuproxy"
	"qiniu.com/qtest/biz/rs"
	"qiniu.com/qtest/biz/rsf"
	"qiniu.com/qtest/biz/specalfunc"
	"qiniu.com/qtest/biz/up"
	"qiniu.com/qtest/configs"
	"qiniu.com/qtest/data"
	"qiniu.com/qtest/lib/auth"
	"qiniu.com/qtest/lib/qnhttp"
	"qiniu.com/qtest/lib/util"
)

var _ = Describe("common api test", func() {

	Context("test api, bucket", func() {

		Context("test api, make, delete bucket, bucket info", func() {

			user := configs.GeneralUser
			bucket := "test_api_bucket_" + util.RandString(10)

			It("xxxx, make bucket", func() {
				user = configs.BucketUser
				bucket = "test_KODO_4903_spock_bucket_01"
				args := BucketArgs{
					User:      user,
					BucketKey: bucket,
					Private:   ShareBucket,
					Region:    "z0",
					Global:    false,
				}
				MyMakeBucket(args)
			})

			It("xxxx, delete bucket", func() {
				user = configs.BucketUser
				bucket = "test_api_bucket_4VyPHDTIqb"
				delBucketArgs := rs.MkBucketArgs{
					User:   user,
					Bucket: bucket,
				}
				rs.DelBucketFunc(delBucketArgs, 200, "")
			})

			It("xxxx, get bucket info", func() {
				user = configs.BucketUser
				bucket := "urlrew3bucket_z0"

				args := uc.UcBucketInfoUtlArgs{
					User:   user,
					Bucket: bucket,
				}
				resp, err := uc.V2BucketInfo(args)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).Should(Equal(200))
			})

			It("xxxx, get bucket entry (itbl, phy)", func() {
				user := configs.GeneralUser
				bucket := configs.Configs.Bucket.Publicbucket
				var entry rs.BucketEntry
				rs.GetBucketEntry(user, bucket, &entry)
				fmt.Printf("bucket itbl: %d\n", entry.Itbl)
			})

			It("xxxx, get bucket phytbl", func() {
				bucket = "bucket_test_new_table_zj04"
				resp, err := tblmgr.PhyBuck(user, bucket)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).Should(Equal(200))

				respText := strings.Trim(resp.RawText(), "\"")
				fmt.Println("***** phytbl:", strings.Split(respText, ":")[0])
			})

			It("xxxx, get bucket by domain", func() {
				user := configs.AdminUser
				testDomain := "urlrew2.com1.z0.glb.clouddn.com"
				resp, err := domain.GetByDomain(user, testDomain)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).Should(Equal(200))
			})

			It("xxxx, bucket transfer", func() {
				type TransferArgs struct {
					BucketName string `flag:"_"`
					UidDest    uint32 `flag:"to"`
					UtypeDest  uint32 `flag:"utypeto"`
					UidSrc     uint32 `flag:"uid"`
				}

				args := TransferArgs{
					BucketName: "change",
					UidSrc:     1380485361,
					UidDest:    1810616643,
					UtypeDest:  4,
				}
				resp, _ := tblmgr.TransferBucket(args.BucketName, args.UidDest, args.UtypeDest, args.UidSrc)
				Expect(resp.Status()).To(Equal(200))
			})
		})

		Context("test api, publish, list domain", func() {

			user := configs.BucketUser

			It("xxxx, publish domain", func() {
				bucket := "urlrew3bucket_z0"
				testDomain := "urlrew3.com1.z0.glb.clouddn.com"

				args := domain.PublishDomainArgsFunc{
					Args: domain.PublishDomainArgs{
						Bucket: bucket,
						Domain: testDomain,
						User:   user,
					},
					Status: 200,
				}
				domain.PublishOnOneFunc(args)
			})

			It("xxxx, get bucket domains v1/v2", func() {
				bucket := "urlrew3bucket_z0"
				args2 := domain.GetDomainsArgsFunc{
					Args: domain.GetDomainsArgs{
						Prefix: "/v2",
						User:   user,
						Bucket: bucket,
					},
					Status: 200,
				}
				domain.GetDomainsOnOneFunc(args2)
			})

			It("xxxx, get bucket domains v3", func() {
				bucket := "urlrew3bucket_z0"
				domains := domain.GetDomainV3Frist(user, bucket)
				fmt.Printf("***** domains: %v", domains)
			})
		})

		Context("test api, make and delete line bucket", func() {

			args := BucketArgs{
				User:      configs.GeneralUser,
				BucketKey: configs.Configs.Bucket.LineBucket,
			}
			suInfo := strconv.FormatUint(uint64(configs.GeneralUser.Uid), 10) + "/0"

			// pre-condition:
			// qboxbucket.conf => "disable_mk_line_bucket" = false
			It("make line bucket", func() {
				retBucket := rs.NewLineBucket(suInfo)
				fmt.Println("***** make bucket success:", retBucket)
			})

			It("delete line bucket", func() {
				delBucketArgs := rs.MkBucketArgs{
					User:   args.User,
					Bucket: args.BucketKey,
				}
				rs.DelBucketFunc(delBucketArgs, 200, "")
			})
		})

		Context("test api, uc", func() {

			user := configs.BucketUser
			bucket := "bucket_test_gray_user_zj04"

			It("xxxx, bucket bind mirror url", func() {
				bucket = "Bucket1cW9nnH7"
				imageArgs := uc.ImageArgs{
					User:       user,
					Bucket:     bucket,
					SrcSiteUrl: "http://callback.dev.qiniu.io",
				}
				resp, err := uc.Image(imageArgs)
				Expect(err).To(BeNil())
				Expect(resp.Status()).To(Equal(200))
			})

			It("xxxx, bucket unbind mirror url", func() {
				resp, err := uc.Unimage(user, bucket)
				Expect(err).To(BeNil())
				Expect(resp.Status()).To(Equal(200))
			})

			It("xxxx, test api, /noIndexPage", func() {
				bucket = "Bucket1cW9nnH7"

				addr := configs.Configs.Host.UC + "/noIndexPage?"
				query := url.Values{}
				query.Add("bucket", bucket)
				query.Add("noIndexPage", "1")
				addr += query.Encode()

				token := auth.SignQboxToken(user, addr, "")
				req := qnhttp.New().Set("Authorization", "QBox "+token)
				resp, err := req.Post(addr, nil, nil, nil)
				Expect(err).To(BeNil())
				Expect(resp.Status()).To(Equal(200))
			})
		})

		Context("test api, tblmgr", func() {

			It("bucket设置空间配额", func() {
				user := configs.BucketUser
				bucket := "tblmgr_test_" + util.RandString(10)

				By("make bucket.")
				args := BucketArgs{
					User:      user,
					BucketKey: bucket,
					Private:   ShareBucket,
					Region:    "z0",
					Global:    false,
				}
				MyMakeBucket(args)
				defer rs.DeleteBucket(user, bucket)

				By("设置bucket空间配额")
				const (
					initSize  = int64(20)
					initCount = int64(10)
				)
				resp, err := tblmgr.SetbucketquotaAdmin(user.Uid, bucket, initSize, initCount)
				Expect(err).NotTo(HaveOccurred())
				Expect(resp.Status()).To(Equal(http.StatusOK))

				By("获取bucket空间配额设置")
				resp, err = tblmgr.GetbucketquotaAdmin(user.Uid, bucket)
				Expect(err).NotTo(HaveOccurred())
				Expect(resp.Status()).To(Equal(http.StatusOK))

				var bucketquota tblmgr.BucketQuota
				resp.ResponseBodyAsRel(&bucketquota)
				fmt.Printf("***** size %d, count %d\n", bucketquota.Size, bucketquota.Count)
			})
		})

	})

	Context("test api, io, up", func() {

		Context("test api, up and download file", func() {

			user := configs.GeneralUser
			bucket := configs.Configs.Bucket.Publicbucket
			key := "io_test_" + util.RandString(10)

			It("upload file", func() {
				user = configs.BucketUser
				bucket = "io_test_dev_0628"
				uploadArgs := up.UploadFileFuncArgs{
					UpArgs: up.UploadFileArgs{
						User:     user,
						Bucket:   bucket,
						FilePath: data.UPLOAD_PIC,
						Key:      key,
					},
					Status: 200,
				}
				up.UploadFileFuncByFilePathNew(uploadArgs)
			})

			It("test api, remove file", func() {
				bucket = "io_test_dev_0628"
				key = "io_test_O9Mib0Ca"
				rs.DeleteFile(user, bucket, key)
			})

			It("xxxx, list and remove batch of files", func() {
				user = configs.BucketUser
				bucket = "kfile_dev_test_pub_bucket"

				listParam := rsf.ListParam{
					Bucket:     bucket,
					Limit:      500,
					IsVersion2: false,
				}
				resp, _ := rsf.List(user, listParam)
				Expect(resp.Status()).To(Equal(200))

				if listParam.IsVersion2 {
					fmt.Println(resp.RawText())
					return
				}

				var dumpRet rsf.DumpRet
				resp.Unmarshal(&dumpRet)

				count := 0
				isDelete := false
				for _, item := range dumpRet.Items {
					count++
					if isDelete {
						fmt.Printf("file: %+v\n", item.Key)
						rs.DeleteFile(user, bucket, item.Key)
					}
				}
				fmt.Println("files count:", count)
			})

			It("test api, get file state", func() {
				user = configs.GeneralUser
				bucket = "publicbucket_z0"
				key = "7hv34aiR"

				By("get file status")
				time.Sleep(time.Second)
				resp, _ := rs.Stat(user, bucket+":"+key)
				Expect(resp.Status()).To(Equal(http.StatusOK))

				By("get file entry (fsize, fh)")
				entryArgs := rs.EntryInfoArgs{
					Uid:    user.Uid,
					Bucket: bucket,
					Key:    key,
				}
				rs.GetEntryInfoRet(entryArgs)

				By("download file")
				getargs := io.IoGetDownArgs{
					User:   user,
					Bucket: bucket,
					Key:    key,
					Status: 200,
				}
				io.IoGetDownByHostFunc(getargs)
			})

			It("xxxx, smoke, test api, upload and download file", func() {
				user := configs.GeneralUser
				bucket := configs.Configs.Bucket.Publicbucket
				key := "io_test_" + util.RandString(8)

				// user = configs.BucketUser
				// bucket = "test_io_qiniuproxy_zj02_mirror"
				// key = "test_mirror_file_zj_02"

				By("upload file")
				uploadArgs := up.UploadFileArgs{
					User:     user,
					Bucket:   bucket,
					FilePath: data.UPLOAD_TEXT,
					// FilePath: data.VideoFormat["mp4"],
					Key: key,
				}
				res, err := up.UploadFile(uploadArgs)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(res.Status()).Should(Equal(200))
				defer rs.DeleteFile(user, bucket, key)

				By("get file status")
				time.Sleep(time.Second)
				resp, err := rs.Stat(user, bucket+":"+key)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).To(Equal(http.StatusOK))

				By("get file fh")
				entryArgs := rs.EntryInfoArgs{
					Uid:    user.Uid,
					Bucket: bucket,
					Key:    key,
				}
				rs.GetFh(entryArgs)

				By("download file")
				getargs := io.IoGetDownArgs{
					User:   user,
					Bucket: bucket,
					Key:    key,
					Status: 200,
				}
				io.IoGetDownByHostFunc(getargs)
			})

			Context("test api, download file by fh", func() {

				// TODO: adminDoraGet()

				It("download file by fh", func() {
					By("get file entry.")
					entryArgs := rs.EntryInfoArgs{
						Uid:    user.Uid,
						Bucket: bucket,
						Key:    key,
					}
					entryInfo := rs.GetEntryInfoRet(entryArgs)

					args := adminDoraGetArgs{
						AdminUser: configs.AdminUser,
						FH:        entryInfo.EncodedFh,
						Fsize:     strconv.Itoa(int(entryInfo.Fsize)),
						// UID:       strconv.Itoa(int(user.Uid)),
						// Bucket: bucket,
						// Range: "0-1024",
					}
					resp, err := adminDoraGet(args)
					Expect(err).ShouldNot(HaveOccurred())
					Expect(resp.Status()).Should(Equal(200))
				})

				It("(old) test api, download file by fh and range", func() {
					fh := ""
					fsize := int64(1024)

					efh := FormatFhToEfh(fsize, fh)
					args := FileArgs{
						User:       configs.GeneralUser,
						EncodedEFh: efh,
						Range:      "byte=0-20971521",
					}
					resp, _ := DownFileByFH(args)
					Expect(resp.Status()).Should(Equal(206))
					Expect(len(resp.RawText())).Should(Equal(fsize))
				})
			})

			It("test api, GET /getByAccess?key=<AccessKey>", func() {
				key := configs.GeneralUser.Key
				addr := configs.Configs.Host.ONE + "/getByAccess?key=" + key
				CommGetRequest(addr)
			})
		})

	})

	Context("test api, rs", func() {
		user := configs.GeneralUser
		bucket := configs.Configs.Bucket.Publicbucket
		key := "rs_test_" + util.RandString(8)

		It("remove file", func() {
			key := "/test/listfiles/qnW628Kg"
			rs.DeleteFile(user, bucket, key)
		})

		It("api, /chgm", func() {
			By("upload file.")
			baseMetaInfos := rs.MapS{"key1": util.EncodeURL("value1")}
			rs.UploadFileFunc(user, bucket, key, baseMetaInfos, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("change file meta data.")
			newMetaInfos := rs.MapS{"key1": util.EncodeURL("value2")}
			rs.ChgmOptFunc(user, bucket, key, newMetaInfos, 200, "")

			By("get file stat.")
			resp, _ := rs.Stat(user, bucket+":"+key)
			Expect(resp.Status()).To(Equal(200))
		})

		It("api, /chtype", func() {
			By("upload file.")
			baseMetaInfos := rs.MapS{"key1": util.EncodeURL("value1")}
			rs.UploadFileFunc(user, bucket, key, baseMetaInfos, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("update file type.")
			args := rs.ChtypeArgs{
				User:     user,
				Bucket:   bucket,
				Key:      key,
				FileType: 1,
			}
			resp, _ := rs.Chtype(args)
			Expect(resp.Status()).To(Equal(200))

			By("get file stat.")
			resp, _ = rs.Stat(user, bucket+":"+key)
			Expect(resp.Status()).To(Equal(200))
		})

		It("api, /adminchtype", func() {
			By("upload file.")
			baseMetaInfos := rs.MapS{"key1": util.EncodeURL("value1")}
			rs.UploadFileFunc(user, bucket, key, baseMetaInfos, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("admin update file type.")
			args := rs.ChtypeArgs{
				User:     user,
				Bucket:   bucket,
				Key:      key,
				FileType: 1,
			}
			resp, _ := rs.AdminChTypeFileFunc(args)
			Expect(resp.Status()).To(Equal(200))

			By("get file stat.")
			resp, _ = rs.Stat(user, bucket+":"+key)
			Expect(resp.Status()).To(Equal(200))
		})

		It("api, /deleteAfterDays", func() {
			By("upload file with lifecycle.")
			rs.PutPolicy(user, bucket, key, 5, data.UPLOAD_PIC, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("set delete file after days.")
			args := rs.AdminDeleteAfterDaysArgs{
				User:            user,
				Bucket:          bucket,
				Key:             key,
				DeleteAfterDays: 1,
			}
			resp, _ := rs.DeleteAfterDays(args)
			Expect(resp.Status()).To(Equal(200))

			By("get file stat.")
			resp, _ = rs.Stat(user, bucket+":"+key)
			Expect(resp.Status()).To(Equal(200))
		})

		It("api, /adminDeleteAfterDays", func() {
			By("upload file.")
			rs.PutPolicy(user, bucket, key, 5, data.UPLOAD_PIC, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("set delete file after days")
			args := rs.AdminDeleteAfterDaysArgs{
				Bucket:          bucket,
				Key:             key,
				DeleteAfterDays: 1,
				Uid:             user.Uid,
			}
			resp, _ := rs.AdminDeleteAfterDays(args)
			Expect(resp.Status()).To(Equal(200))

			By("get file stat.")
			resp, _ = rs.Stat(user, bucket+":"+key)
			Expect(resp.Status()).To(Equal(200))
		})

		It("api, /admin/updatefh", func() {
			By("upload file.")
			up.UploadFileFuncByFilePath(user, data.UPLOAD_PIC, bucket, key, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("get upload file fh.")
			entryArgs := rs.EntryInfoArgs{
				Uid:    user.Uid,
				Bucket: bucket,
				Key:    key,
			}
			encodedfh := rs.GetFh(entryArgs)

			By("update fh.")
			encodedNewFh := ""
			fh, _ := base64.URLEncoding.DecodeString(encodedfh)
			newFh, _ := base64.URLEncoding.DecodeString(encodedNewFh)
			args := rs.UpdateFhArgs{
				Uid:    user.Uid,
				Bucket: bucket,
				Key:    key,
				OldFh:  fh,
				NewFh:  newFh,
				User:   configs.AdminUser,
			}
			resp, _ := rs.AdminUpdateFh(args)
			Expect(resp.Status()).To(Equal(200))

			By("get file stat.")
			rs.GetFh(entryArgs)
		})

		It("api, /admin/put, 01", func() {
			By("upload file.")
			baseMetaInfos := rs.MapS{"key1": util.EncodeURL("value1")}
			rs.UploadFileFunc(user, bucket, key, baseMetaInfos, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("get upload file fh.")
			entryArgs := rs.EntryInfoArgs{
				Uid:    user.Uid,
				Bucket: bucket,
				Key:    key,
			}
			resp, _ := rs.EntryInfo(entryArgs)
			retJson := resp.ResponseBodyAsJson()
			fh := retJson["fh"].(string)
			fsize := retJson["fsize"].(float64)
			hash := retJson["hash"].(string)
			mimeType := retJson["mimeType"].(string)
			putTime := retJson["putTime"].(float64)

			By("update file.")
			url := configs.Configs.Host.RS_INTERAL + "/admin/put/" + util.EncodeURL(bucket+":"+key)
			url += fmt.Sprintf("/fsize/%d/hash/%s/mimeType/%s", int(fsize), hash, util.EncodeURL(mimeType))
			url += fmt.Sprintf("/uid/%d/putTime/%d", user.Uid, int64(putTime))
			url += "/x-qn-meta-key1/" + util.EncodeURL("value2")

			token := auth.SignQboxToken(configs.AdminUser, url, fh)
			s := qnhttp.New().Set("Authorization", "QBox "+token)
			resp, _ = s.Post(url, fh, nil, nil)
			Expect(resp.Status()).Should(Equal(200))

			By("get file stat.")
			rs.GetFh(entryArgs)
		})

		It("api, /admin/put, 02", func() {
			By("upload file.")
			baseMetaInfos := rs.MapS{"key1": util.EncodeURL("value1")}
			rs.UploadFileFunc(user, bucket, key, baseMetaInfos, 200, "")
			defer rs.DeleteFile(user, bucket, key)

			By("get upload file fh.")
			entryArgs := rs.EntryInfoArgs{
				Uid:    user.Uid,
				Bucket: bucket,
				Key:    key,
			}
			resp, _ := rs.EntryInfo(entryArgs)
			retJson := resp.ResponseBodyAsJson()
			fh := retJson["fh"].(string)
			fsize := retJson["fsize"].(float64)
			hash := retJson["hash"].(string)
			mimeType := retJson["mimeType"].(string)
			putTime := retJson["putTime"].(float64)
			IP := retJson["ip"].(string)
			fmt.Println("*****ip:", IP)

			By("update file.")
			args := rs.AdminPutInsArgs{
				User:            configs.AdminUser,
				Method:          "put",
				Entry:           bucket + ":" + key,
				FileSize:        int64(fsize),
				Hash:            hash,
				Mimetype:        mimeType,
				Uid:             user.Uid,
				Fh:              []byte(fh),
				EncodeMetaInfos: rs.MapS{"key1": "value2"},
				Ip:              IP,
				PutTime:         int64(putTime),
			}
			resp, _ = rs.AdminPutIns(args)
			Expect(resp.Status()).Should(Equal(200))

			By("get file stat.")
			rs.GetFh(entryArgs)
		})

	})

	Context("test api, rsf", func() {

		user := configs.GeneralUser
		bucket := configs.Configs.Bucket.Publicbucket

		It("xxxx, list files in bucket", func() {
			user = configs.BucketUser
			bucket = "ftp_dev_test_pub_bucket"
			isVersion2 := false

			listParam := rsf.ListParam{
				Bucket:     bucket,
				Limit:      500,
				IsVersion2: isVersion2,
			}
			resp, _ := rsf.List(user, listParam)
			Expect(resp.Status()).To(Equal(200))

			if !isVersion2 { // version1
				var dumpRet rsf.DumpRet
				resp.Unmarshal(&dumpRet)

				marker, _ := util.Decode(util.EncodeType_Base64, dumpRet.Marker)
				fmt.Printf("marker: %v\n", marker)

				fmt.Println("items:")
				for _, item := range dumpRet.Items {
					fmt.Printf("%+v\n", item)
				}
			}
		})

		It("admin list files in bucket", func() {
			args := rsf.AdminListParam{
				Region: "z0",
				Itbl:   511087169,
			}
			res, _ := rsf.AdminList(configs.AdminUser, args)
			Expect(res.Status()).To(Equal(200))
			fmt.Println(res.RawText())
		})

		Context("test api, create files and list", func() {

			user := configs.BucketUser
			bucket := "test_api_bucket_urts6VPcDs"

			It("make bucket", func() {
				args := BucketArgs{
					User:      user,
					BucketKey: bucket,
					Private:   ShareBucket,
					Region:    "z0",
					Global:    false,
				}
				MyMakeBucket(args)
			})

			It("upload multiple files", func() {
				const count = 1
				uploadArgs := up.UploadFileArgs{
					User:     user,
					Bucket:   bucket,
					FilePath: "/Users/zhengjin/Downloads/tmp_files/upload.txt",
				}
				for i := 0; i < count; i++ {
					uploadArgs.Key = fmt.Sprintf("zhengjin/atestC/io_1_%d", i)
					up.UploadFile(uploadArgs)
				}
			})

			It("copy files", func() {
				const count = 30
				args := rs.CopyArgs{
					User:     user,
					SrcEntry: bucket + ":" + "zhengjin/bigData/io_1_1",
				}
				for i := 0; i < count; i++ {
					args.TargetEntry = bucket + ":" + fmt.Sprintf("zhengjin/bigData/io_2_%d", i)
					rs.Copy(args)
				}
			})

			Context("list files", func() {

				user := configs.BucketUser
				const (
					bucket = "test_api_bucket_urts6VPcDs" // 8h0ayi
					prefix = "/zhengjin/dataD/"
					limit  = 50
					// marker = "eyJjIjowLCJrIjoiL3poZW5namluL2RhdGFCL3Rlc3Q5Yjk5NSJ9"
				)

				It("xxxx, v1 list files by delimiter", func() {
					listParam := rsf.ListParam{
						Bucket: bucket,
						// Limit:     limit,
						Prefix:    prefix,
						Delimiter: "/",
						// Marker:    marker, // return last position
					}
					args := rsf.ListFuncArgs{
						User:          user,
						ListParamArgs: listParam,
						Status:        200,
					}
					// rsf.List(args.User, listParam)
					resp, _ := rsf.List(args.User, listParam)
					// fmt.Println("***** response:", resp.RawText())

					// display
					var dumpRet rsf.DumpRet
					resp.Unmarshal(&dumpRet)

					if len(dumpRet.Marker) > 0 {
						marker, _ := util.Decode(util.EncodeType_Base64, dumpRet.Marker)
						fmt.Printf("***** marker: %v => %v\n", dumpRet.Marker, marker)
					}

					fmt.Printf("items: %d\n", len(dumpRet.Items))
					if len(dumpRet.Items) < 100 {
						for _, item := range dumpRet.Items {
							if b, err := json.MarshalIndent(item, "", "  "); err == nil {
								fmt.Println(string(b))
							}
						}
					}

					fmt.Println("dirs:")
					for _, dir := range dumpRet.CommonPrefixes {
						fmt.Println(dir)
					}
				})

				It("v2 list files by delimiter", func() {
					listParam := rsf.ListParam{
						IsVersion2: true,
						Bucket:     bucket,
						// Limit:      limit,
						Prefix:    prefix,
						Delimiter: "/",
						// Marker:    marker, // return last position
					}
					args := rsf.ListFuncArgs{
						User:          user,
						ListParamArgs: listParam,
						Status:        200,
					}
					// rsf.List(args.User, listParam)
					resp, _ := rsf.List(args.User, listParam)
					Expect(resp.Status()).Should(Equal(200))

					isOutputFile := false
					if isOutputFile {
						filePath := "/Users/zhengjin/Downloads/tmp_files/listfile.output"
						if err := ioutil.WriteFile(filePath, []byte(resp.RawText()), 0666); err != nil {
							fmt.Println(err.Error())
						}
					} else {
						fmt.Println("***** resp body:\n", resp.RawText())
					}
				})
			})

		})
	})

	Context("test api, pfd", func() {

		fh := ""

		It("get fh info from stg", func() {
			fhMoreInfo := pfd.GetFhMoreInfoFunc(fh)
			fmt.Printf("*****fh info: %+v\n", fhMoreInfo)
			specalfunc.Logfhinfofunc(fh)
		})

		It("get file from ebddn by fh", func() {
			e := ebd.New(ebd.Conf{})
			e.EbddnGet(fh)
		})
	})

	Context("test api, qiniuproxy", func() {

		user := configs.GeneralUser
		bucket := configs.Configs.Bucket.Publicbucket

		It("access qiniuproxy", func() {
			urlCallBack := "http://callback.dev.qiniu.io/slowResponse?sleep=1"
			args := qiniuproxy.MirrorArgs{
				Host:   configs.Configs.Host.QINIUPROXY,
				Uid:    user.Uid,
				Bucket: bucket,
				Url:    urlCallBack,
			}
			resp, err := qiniuproxy.Mirror(args)
			Expect(err).ShouldNot(HaveOccurred())
			Expect(resp.Status()).To(Equal(200))
		})

		It("bucket bind mirror url", func() {
			// http://callback.dev.qiniu.io/slowResponse?sleep=1
			imageArgs := uc.ImageArgs{
				User:       user,
				Bucket:     bucket,
				SrcSiteUrl: "http://10.200.20.21:17890",
			}
			resp, err := uc.Image(imageArgs)
			Expect(err).To(BeNil())
			Expect(resp.Status()).To(Equal(200))
		})

		It("access qiniuproxy by io mirror", func() {
			user := configs.BucketUser
			bucket := "io_limit_test_" + util.RandString(10)

			By("make bucket.")
			mkBucketArgs := rs.MkBucketArgs{
				User:   user,
				Bucket: bucket,
			}
			res, _ := rs.MkBucket(mkBucketArgs)
			Expect(res.Status()).To(Equal(200))
			defer rs.DeleteBucket(user, bucket)

			By("set image.")
			// http://callback.dev.qiniu.io/slowResponse?sleep=1
			imageArgs := uc.ImageArgs{
				User:       user,
				Bucket:     bucket,
				SrcSiteUrl: "http://callback.dev.qiniu.io",
			}
			resp, err := uc.Image(imageArgs)
			Expect(err).To(BeNil())
			Expect(resp.Status()).To(Equal(200))

			By("download file by mirror.")
			srcKey := fmt.Sprintf("slowResponse?sleep=1&bucket=%s", bucket)
			getargs := io.IoGetDownArgs{
				User:   user,
				Bucket: bucket,
				Key:    url.QueryEscape(srcKey),
				Status: 200,
			}
			io.IoGetDownByHostFunc(getargs)
			// manual check callback server log
		})

	})

	Context("xxxx, set fop style", func() {

		user := configs.BucketUser
		bucket := "test_io_qiniuproxy_zj02_tobucket"

		It("xxxx, set fop style, pre-condition", func() {
			By("设置fop样式分隔符")
			const separator = "-"
			res, err := uc.Separator(user, bucket, separator)
			Expect(err).ShouldNot(HaveOccurred())
			Expect(res.Status()).Should(Equal(200))

			By("下载时, 优先认为style作为key的一部分")
			args := uc.PreferStyleAsKeyArgs{
				User:   user,
				Bucket: bucket,
				Toggle: true,
			}
			res, err = uc.PreferStyleAsKey(args)
			Expect(err).ShouldNot(HaveOccurred())
			Expect(res.Status()).Should(Equal(200))
		})

		const styleName = "zjstyle"
		It("xxxx, set fop style", func() {
			By("设置fop样式")
			const style = "imageView2/1/w/300/h/150/q/80"
			styleArgs := uc.StyleArgs{
				User:      user,
				Bucket:    bucket,
				StyleName: styleName,
				Style:     style,
			}
			res, err := uc.Style(styleArgs)
			Expect(err).ShouldNot(HaveOccurred())
			Expect(res.Status()).Should(Equal(200))
		})

		It("xxxx, 取消fop样式", func() {
			styleArgs := uc.StyleArgs{
				User:      user,
				Bucket:    bucket,
				StyleName: styleName,
			}
			res, err := unStyle(styleArgs)
			Expect(err).ShouldNot(HaveOccurred())
			Expect(res.Status()).Should(Equal(200))
		})

		It("xxxx, get bucket info for fop", func() {
			infoArgs := uc.UcBucketInfoUtlArgs{
				User:   user,
				Bucket: bucket,
			}
			resp, err := uc.V2BucketInfo(infoArgs)
			Expect(err).ShouldNot(HaveOccurred())
			Expect(resp.Status()).Should(Equal(200))
			fmt.Printf("user id: %d\n", user.Uid)
		})
	})

	Context("test, io mirror by url", func() {

		user := configs.BucketUser
		mirror := "10.200.20.21:17890"
		toBucket := "test_io_qiniuproxy_zj02_tobucket"

		It("xxxx, io mirror by url, basic", func() {
			query := url.Values{}
			query.Add("isFile", "true")
			query.Add("key", "testdevpic1")
			key := "index4/?" + query.Encode()

			args := io.QiNiuMirrorArgs{
				User: user,
				// MirrorBucket: mirrorBucket,
				MirrorURL: mirror,
				Tobucket:  toBucket,
				Key:       key,
			}
			resp, err := io.QiNiuMirrorByURL(args)
			defer func() {
				time.Sleep(500 * time.Millisecond)
				rs.DeleteFile(user, toBucket, key)
			}()
			Expect(err).ShouldNot(HaveOccurred())
			Expect(resp.Status()).To(Equal(200))
		})

		It("xxxx, io mirror by url, fop", func() {
			query := url.Values{}
			query.Add("isFile", "true")
			query.Add("key", "testfoppic1")
			key := "index4/?" + query.Encode()

			args := io.QiNiuMirrorArgs{
				User: user,
				Fop:  url.QueryEscape("imageView2/1/w/300/h/150/q/80"),
				// MirrorBucket: mirrorBucket,
				MirrorURL: mirror,
				Tobucket:  toBucket,
				Key:       key,
			}
			// save src file in toBucket, and return fop file
			resp, err := io.QiNiuMirrorByURL(args)
			defer func() {
				time.Sleep(500 * time.Millisecond)
				rs.DeleteFile(user, toBucket, key)
			}()
			Expect(err).ShouldNot(HaveOccurred())
			Expect(resp.Status()).To(Equal(200))
			saveFile(resp.BodyToByte())
		})

		It("xxxx, remove file", func() {
			key := "index4/?isFile=true&key=testpic1"
			rs.DeleteFile(user, toBucket, key)
		})

	})

	Context("test api, kmq", func() {

		user := configs.GeneralUser
		queueUid := user.Uid

		Context("kmq, create and delete queue", func() {

			args := kmq.QueueArgs{
				User: configs.AdminUser,
				Uid:  queueUid,
				Name: "ZjQueue" + util.RandString(8),
				// ZjQueueqWzsqNpX
				Retention: "1", // 消息保留的天数
			}

			It("xxxx, create queue", func() {
				resp, err := kmq.CreateQueue(args)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).Should(Equal(200))
			})

			It("xxxx, delete queue", func() {
				args.Name = "ZjQueue0X1AX8Kr"
				resp, err := kmq.DeleteQueue(args)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).Should(Equal(200))
			})

			It("xxxx, get list of queue", func() {
				resp, err := kmq.GetQueues(configs.AdminUser, queueUid)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).To(Equal(200))
				fmt.Println("***** list of queue:", resp.RawText())
			})
		})

		Context("kmq, produce and consume message", func() {

			queueName := "ZjQueueqWzsqNpX"
			checkMsg := "zj_test_msg_for_stream_datax"

			It("xxxx, produce message", func() {
				const (
					threads = 1
					count   = 10
				)

				args := kmq.ProduceMsgArgs{
					User: configs.AdminUser,
					// User:      user, // msg size limit 4096
					QueueName: queueName,
					Uid:       user.Uid,
				}

				var wg sync.WaitGroup
				for i := 0; i < threads; i++ {
					wg.Add(1)
					go func(wg *sync.WaitGroup, idx int) {
						defer wg.Done()
						defer GinkgoRecover()
						var msgs []string
						for j := 0; j < count; j++ {
							// msgs = append(msgs, customMsg) // insert specific msg
							msgs = append(msgs, fmt.Sprintf("zj%d-%d", idx, j)+util.GetRand(30))
						}
						args.Msgs = msgs
						// resp, err := kmq.Produce(args)
						resp, err := kmq.AdminProduceMsg(args)
						Expect(err).ShouldNot(HaveOccurred())
						Expect(resp.Status()).To(Equal(200))
					}(&wg, i)
				}
				wg.Wait()
			})

			It("xxxx, consume message", func() {
				args := kmq.ConsumeMsgArgs{
					User:      user,
					QueueName: queueName,
					Limit:     "30",
					// Position:  "",
				}

				var consumeRet kmq.QueueConsumeRet
				resp, err := kmq.Consume(args)
				Expect(err).ShouldNot(HaveOccurred())
				Expect(resp.Status()).Should(Equal(200))

				err = json.Unmarshal([]byte(resp.RawText()), &consumeRet)
				Expect(err).ShouldNot(HaveOccurred())
				fmt.Println("***** position:", consumeRet.Position)
				for idx, msg := range consumeRet.Msgs {
					fmt.Printf("msg-%d: %s\n", idx, msg)
				}
			})

			It("xxxx, stream consume message", func() {
				type StreamMsg struct {
					Position string `json:"position"`
					Message  string `json:"message"`
				}

				streamConsume := func(args kmq.ConsumeMsgArgs) {
					// proxy by aipserver
					u := configs.Configs.Host.KMQ + "/queues/" + args.QueueName + "/stream/consume"
					// access kmq
					// u := "http://10.200.20.36:14532" + "/queues/" + args.QueueName + "/stream/consume"
					v := url.Values{}
					if len(args.Limit) > 0 {
						v.Add("position", args.Position)
					}
					url := u + "?" + v.Encode()
					fmt.Println("url:", url)

					req, err := http.NewRequest("GET", url, nil)
					Expect(err).ShouldNot(HaveOccurred(), "build request failed.")
					token := auth.SignQboxToken(args.User, url, "")
					req.Header.Add("Authorization", "QBox "+token)

					// handle resp headers
					client := &http.Client{}
					resp, err := client.Do(req)
					Expect(err).ShouldNot(HaveOccurred(), "send request failed.")
					defer resp.Body.Close()
					fmt.Println("***** Status:", resp.StatusCode)
					fmt.Printf("***** Response header %v\n", resp.Header)
					if resp.StatusCode != 200 {
						time.Sleep(time.Second)
						output, err := ioutil.ReadAll(resp.Body)
						Expect(err).ShouldNot(HaveOccurred(), "read response body failed.")
						if len(output) > 0 {
							fmt.Println("***** Error message:", string(output))
						}
						return
					}

					// stream read
					ch := make(chan bool)
					go func() {
						fmt.Println("***** Stream data:")
						total := 0
						decStream := json.NewDecoder(resp.Body)
						for {
							total++
							var msg StreamMsg
							err := decStream.Decode(&msg) // read one record
							if err != nil {
								fmt.Println(err.Error())
								ch <- false
								return
							}
							if total%1000 == 0 {
								fmt.Printf("***** iterator at %d\n", total)
								fmt.Printf("{position: %s, msg: %s}\n", msg.Position, msg.Message)
							}
							if msg.Message == checkMsg {
								fmt.Println("***** message found!")
								ch <- true
								return
							}
							// time.Sleep(300 * time.Millisecond)
						}
					}()
					select {
					case <-time.After(60 * time.Second):
						Fail("stream consume timeout.")
					case ret := <-ch:
						Expect(ret).Should(BeTrue())
					}
				}

				const threads = 1
				var wg sync.WaitGroup
				args := kmq.ConsumeMsgArgs{
					User:      user,
					QueueName: queueName,
					Position:  "",
				}
				for i := 0; i < threads; i++ {
					wg.Add(1)
					go func(wg *sync.WaitGroup, idx int) {
						defer wg.Done()
						defer GinkgoRecover()
						streamConsume(args)
						fmt.Printf("***** stream consume thread-%d done\n", idx)
					}(&wg, i)
				}
				wg.Wait()
			})
		})
	})

	Context("test api, check log", func() {
		It("xxxx, check audit log", func() {
			reqid := "KCYAAP0KXJQOJRsV"
			auditPath := " /home/qboxserver/io/_package/run/auditlog/io"
			// io.GetIOAuditlog()
			ret, err := util.GetAuditlog(configs.Configs.Host.IO, auditPath, reqid, "")
			log.Printf("\naudit log: %s\n", ret)
			Expect(err).NotTo(HaveOccurred())
			Expect(ret).To(ContainSubstring("///file-url-rewrite-C6fQBVTHAb"))
		})

		It("check cs1 testserver log", func() {
			key := "io_limit_test_PwrH8mHoJU"
			path := "/home/qboxserver/.testserver"
			sshCmd := util.SSHCommander{User: "qboxserver", Host: "cs1"}
			cmds := []string{fmt.Sprintf("grep -r %s %s", key, path)}
			ret, _ := sshCmd.Command(cmds...).CombinedOutput()
			fmt.Println("log output:", string(ret))
		})
	})

})

const (
	ShareBucket   = "0"
	PrivateBucket = "1"
)

type BucketArgs struct {
	User      auth.AccessInfo
	BucketKey string
	Private   string
	Region    string
	Global    bool
}

func MyMakeBucket(args BucketArgs) {
	mkBucketArgs := rs.MkBucketArgs{
		User:   args.User,
		Bucket: args.BucketKey,
	}
	res, _ := rs.MkBucket(mkBucketArgs)
	Expect(res.Status()).To(Equal(200))

	if args.Private == PrivateBucket {
		privateArgs := uc.PrivateArgs{
			User:    args.User,
			Bucket:  args.BucketKey,
			Private: args.Private,
		}

		res, _ = uc.Private(privateArgs)
		Expect(res.Status()).To(Equal(200))
	}
}

func CommGetRequest(addr string) (*qnhttp.Response, error) {
	token := auth.SignQboxToken(configs.AdminUser, addr, "")
	s := qnhttp.New().Set("Authorization", "QBox "+token)
	return s.Get(addr, nil, nil, nil)
}

func CommPostRequest(addr string, params map[string][]string) (*qnhttp.Response, error) {
	msg := url.Values(params).Encode()
	token := auth.SignQboxToken(configs.AdminUser, addr, msg)
	s := qnhttp.New().Set("Authorization", "QBox "+token)
	return s.Post(addr, msg, nil, nil)
}

func FormatFhToEfh(fSize int64, fh string) string {
	strFh, _ := base64.URLEncoding.DecodeString(fh)
	fi := &sstore.FhandleInfo{
		Fhandle:  []byte(strFh),
		Fsize:    fSize,
		Deadline: newtime.Nanoseconds() + (1e9 * int64(3600)),
		KeyHint:  105,
	}
	return sstore.EncodeFhandle(fi, []byte("qbox.rs.test"))
}

type FileArgs struct {
	User       auth.AccessInfo
	EncodedEFh string
	Range      string
}

func DownFileByFH(args FileArgs) (*qnhttp.Response, error) {
	u := configs.Configs.Host.IO + "/file/" + args.EncodedEFh
	token := auth.SignQboxToken(args.User, u, "")
	s := qnhttp.New().Set("Authorization", "QBox "+token)

	if len(args.Range) > 0 {
		s.Header.Add("range", args.Range)
	}

	return s.Get(u, nil, nil, nil)
}
